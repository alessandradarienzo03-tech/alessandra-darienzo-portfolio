# ============================================================
# Hitachi Rail Battery Monitoring
# 02 - Compositional T² Control Chart
# ============================================================
#
# Main statistical workflow:
#   1. represent four parallel-battery current contributions as a composition;
#   2. apply closure;
#   3. transform compositions with ILR coordinates;
#   4. calibrate an in-control Phase I reference iteratively;
#   5. diagnose distributional assumptions;
#   6. monitor later cycles with a Hotelling-type T² / Mahalanobis statistic.
#
# Final project design: first 70 cycles used for initial Phase I calibration.
# ============================================================

required_packages <- c(
  "dplyr",
  "ggplot2",
  "compositions",
  "robCompositions",
  "MVN"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Install the following packages before running this script: ",
    paste(missing_packages, collapse = ", ")
  )
}

library(dplyr)
library(ggplot2)
library(compositions)
library(robCompositions)

# ------------------------------------------------------------
# 1. Load cycle-level data
# ------------------------------------------------------------

data_path <- file.path(
  "data",
  "derived",
  "cycle_level_features.rds"
)

if (!file.exists(data_path)) {
  stop(
    "Cycle-level file not found. Run ",
    "R/01_cycle_level_feature_engineering.R first."
  )
}

cycle_level <- readRDS(data_path)

battery_ids <- c("C2", "C4", "C5", "C7")
current_cols <- paste0("Iabs_", battery_ids)

missing_cols <- setdiff(
  c("cycle_id", current_cols),
  names(cycle_level)
)

if (length(missing_cols) > 0) {
  stop(
    "Missing cycle-level columns: ",
    paste(missing_cols, collapse = ", ")
  )
}

current_data <- cycle_level %>%
  select(
    cycle_id,
    all_of(current_cols)
  ) %>%
  filter(
    if_all(
      all_of(current_cols),
      ~ is.finite(.x) & .x > 0
    )
  )

if (nrow(current_data) <= 70) {
  stop(
    "At least 71 valid cycles are required for ",
    "Phase I / Phase II monitoring."
  )
}

# ------------------------------------------------------------
# 2. Helper functions
# ------------------------------------------------------------

close_and_ilr <- function(x) {
  closed <- robCompositions::constSum(
    as.data.frame(x),
    const = 1
  )

  as.matrix(
    compositions::ilr(closed)
  )
}

phase1_beta_ucl <- function(n, p, alpha = 0.05) {
  if (n <= p + 1) {
    stop(
      "Insufficient Phase I sample size for the Beta control limit."
    )
  }

  shape1 <- p / 2
  shape2 <- (n - p - 1) / 2

  beta_quantile <- qbeta(
    1 - alpha,
    shape1 = shape1,
    shape2 = shape2
  )

  ((n - 1)^2 / n) * beta_quantile
}

calibrate_phase1 <- function(
  raw_matrix,
  alpha = 0.05
) {
  train_ids <- seq_len(nrow(raw_matrix))
  iteration <- 0

  repeat {
    iteration <- iteration + 1

    ilr_data <- close_and_ilr(
      raw_matrix[train_ids, , drop = FALSE]
    )

    n <- nrow(ilr_data)
    p <- ncol(ilr_data)

    center <- colMeans(ilr_data)
    covariance <- cov(ilr_data)

    t2 <- mahalanobis(
      x = ilr_data,
      center = center,
      cov = covariance
    )

    ucl <- phase1_beta_ucl(
      n = n,
      p = p,
      alpha = alpha
    )

    local_outliers <- which(t2 > ucl)

    message(
      sprintf(
        paste0(
          "Phase I iteration %d: n=%d, ",
          "UCL=%.4f, out-of-control=%d"
        ),
        iteration,
        n,
        ucl,
        length(local_outliers)
      )
    )

    if (length(local_outliers) == 0) {
      return(
        list(
          retained_ids = train_ids,
          ilr = ilr_data,
          center = center,
          covariance = covariance,
          t2 = t2,
          ucl = ucl,
          iterations = iteration
        )
      )
    }

    train_ids <- train_ids[-local_outliers]

    if (length(train_ids) <= p + 2) {
      stop(
        "Phase I cleaning removed too many observations."
      )
    }
  }
}

# ------------------------------------------------------------
# 3. Phase I calibration
# ------------------------------------------------------------

n_train <- 70
alpha <- 0.05

raw_composition <- as.matrix(
  current_data[current_cols]
)

phase1_raw <- raw_composition[
  seq_len(n_train),
  ,
  drop = FALSE
]

phase1 <- calibrate_phase1(
  raw_matrix = phase1_raw,
  alpha = alpha
)

phase1_cycle_ids <- current_data$cycle_id[
  seq_len(n_train)
]

retained_cycle_ids <- phase1_cycle_ids[
  phase1$retained_ids
]

cat("\nPhase I calibration complete\n")
cat(
  "Initial cycles:",
  n_train,
  "\n"
)
cat(
  "Retained cycles:",
  length(phase1$retained_ids),
  "\n"
)
cat(
  "Final theoretical Phase I UCL:",
  round(phase1$ucl, 4),
  "\n"
)

# ------------------------------------------------------------
# 4. Distributional diagnostics
# ------------------------------------------------------------
#
# The original project found departures from multivariate normality.
# Diagnostics are therefore reported rather than assumed away.

ilr_phase1 <- phase1$ilr
p <- ncol(ilr_phase1)

shapiro_table <- data.frame(
  coordinate = paste0("ILR_", seq_len(p)),
  W = NA_real_,
  p_value = NA_real_
)

for (j in seq_len(p)) {
  test_result <- shapiro.test(
    ilr_phase1[, j]
  )

  shapiro_table$W[j] <- unname(
    test_result$statistic
  )
  shapiro_table$p_value[j] <- test_result$p.value
}

shapiro_table$p_value_fdr <- p.adjust(
  shapiro_table$p_value,
  method = "fdr"
)

print(shapiro_table)

hz_result <- MVN::mvn(
  data = as.data.frame(ilr_phase1),
  mvn_test = "hz"
)

mardia_result <- MVN::mvn(
  data = as.data.frame(ilr_phase1),
  mvn_test = "mardia"
)

cat("\nHenze-Zirkler diagnostic\n")
print(hz_result$multivariate_normality)

cat("\nMardia diagnostic\n")
print(mardia_result$multivariate_normality)

# Q-Q plots for the three ILR coordinates.
qq_path <- file.path(
  "results",
  "ilr_qq_diagnostics.png"
)

dir.create(
  "results",
  recursive = TRUE,
  showWarnings = FALSE
)

png(
  filename = qq_path,
  width = 1500,
  height = 500,
  res = 150
)

par(mfrow = c(1, p))

for (j in seq_len(p)) {
  qqnorm(
    ilr_phase1[, j],
    main = paste0("Q-Q ILR ", j)
  )
  qqline(
    ilr_phase1[, j],
    lwd = 2
  )
}

par(mfrow = c(1, 1))
dev.off()

# ------------------------------------------------------------
# 5. Empirical Phase II control limit
# ------------------------------------------------------------
#
# Given the observed non-normality, the final monitoring stage
# uses an empirical UCL estimated from the cleaned Phase I T²
# distribution.

t2_phase1_clean <- mahalanobis(
  x = ilr_phase1,
  center = phase1$center,
  cov = phase1$covariance
)

ucl_empirical <- unname(
  quantile(
    t2_phase1_clean,
    probs = 1 - alpha,
    type = 7
  )
)

cat(
  "\nEmpirical Phase II UCL:",
  round(ucl_empirical, 4),
  "\n"
)

# ------------------------------------------------------------
# 6. Phase II monitoring
# ------------------------------------------------------------

all_ilr <- close_and_ilr(
  raw_composition
)

t2_all <- mahalanobis(
  x = all_ilr,
  center = phase1$center,
  cov = phase1$covariance
)

monitoring <- data.frame(
  cycle_id = current_data$cycle_id,
  T2 = as.numeric(t2_all),
  phase = ifelse(
    seq_len(nrow(current_data)) <= n_train,
    "Phase I",
    "Phase II"
  )
)

monitoring$UCL <- ifelse(
  monitoring$phase == "Phase I",
  phase1$ucl,
  ucl_empirical
)

monitoring$out_of_control <- (
  monitoring$T2 > monitoring$UCL
)

phase2_alerts <- monitoring %>%
  filter(
    phase == "Phase II",
    out_of_control
  )

cat(
  "Phase II alerts:",
  nrow(phase2_alerts),
  "of",
  sum(monitoring$phase == "Phase II"),
  "\n"
)

write.csv(
  phase2_alerts,
  file.path(
    "results",
    "phase2_out_of_control_cycles.csv"
  ),
  row.names = FALSE
)

# ------------------------------------------------------------
# 7. Control chart
# ------------------------------------------------------------

p_chart <- ggplot(
  monitoring,
  aes(
    x = cycle_id,
    y = T2
  )
) +
  geom_line(linewidth = 0.45) +
  geom_point(
    aes(
      shape = out_of_control
    ),
    size = 1.7
  ) +
  geom_hline(
    yintercept = phase1$ucl,
    linetype = "dotted"
  ) +
  geom_hline(
    yintercept = ucl_empirical,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = monitoring$cycle_id[n_train],
    linetype = "dotdash"
  ) +
  labs(
    title = "Compositional T² Battery Monitoring",
    subtitle = paste0(
      "Initial Phase I window = ",
      n_train,
      " cycles"
    ),
    x = "Cycle",
    y = expression(T[C]^2),
    shape = "Out of control"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  filename = file.path(
    "results",
    "coda_t2_control_chart.png"
  ),
  plot = p_chart,
  width = 9.5,
  height = 5.2,
  dpi = 180
)

# ------------------------------------------------------------
# 8. Component shares for diagnosis
# ------------------------------------------------------------

closed_all <- robCompositions::constSum(
  as.data.frame(raw_composition),
  const = 1
)

share_df <- as.data.frame(closed_all)
names(share_df) <- battery_ids

share_df$cycle_id <- current_data$cycle_id

write.csv(
  share_df,
  file.path(
    "results",
    "battery_current_shares.csv"
  ),
  row.names = FALSE
)

cat(
  "\nMonitoring outputs saved in the results/ directory.\n"
)
