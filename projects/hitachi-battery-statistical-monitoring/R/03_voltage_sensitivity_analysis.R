# ============================================================
# Hitachi Rail Battery Monitoring
# 03 - Voltage Sensitivity Analysis
# ============================================================
#
# Voltage is used as a complementary view of battery-system behaviour.
# Since parallel-connected batteries should operate at similar voltage
# levels, relative voltage deviations may reveal unusual operating
# conditions, measurement issues or internal-resistance changes.
#
# This script mirrors the compositional logic used for the current-based
# control chart, but voltage remains a secondary diagnostic in the project.
# ============================================================

required_packages <- c(
  "dplyr",
  "ggplot2",
  "compositions",
  "robCompositions"
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
voltage_cols <- paste0("VBatt_", battery_ids)

missing_cols <- setdiff(
  c("cycle_id", voltage_cols),
  names(cycle_level)
)

if (length(missing_cols) > 0) {
  stop(
    "Missing cycle-level voltage columns: ",
    paste(missing_cols, collapse = ", ")
  )
}

voltage_data <- cycle_level %>%
  select(
    cycle_id,
    all_of(voltage_cols)
  ) %>%
  filter(
    if_all(
      all_of(voltage_cols),
      ~ is.finite(.x) & .x > 0
    )
  )

if (nrow(voltage_data) <= 70) {
  stop(
    "At least 71 valid cycles are required for ",
    "Phase I / Phase II monitoring."
  )
}

# ------------------------------------------------------------
# 2. Relative voltage composition
# ------------------------------------------------------------

raw_voltage <- as.matrix(
  voltage_data[voltage_cols]
)

closed_voltage <- robCompositions::constSum(
  as.data.frame(raw_voltage),
  const = 1
)

ilr_voltage <- as.matrix(
  compositions::ilr(closed_voltage)
)

# ------------------------------------------------------------
# 3. Phase I baseline
# ------------------------------------------------------------

n_train <- 70
alpha <- 0.05

phase1_ilr <- ilr_voltage[
  seq_len(n_train),
  ,
  drop = FALSE
]

phase1_ids <- seq_len(n_train)

repeat {
  current_phase1 <- phase1_ilr[
    phase1_ids,
    ,
    drop = FALSE
  ]

  center <- colMeans(current_phase1)
  covariance <- cov(current_phase1)

  t2_phase1 <- mahalanobis(
    x = current_phase1,
    center = center,
    cov = covariance
  )

  empirical_ucl <- unname(
    quantile(
      t2_phase1,
      probs = 1 - alpha,
      type = 7
    )
  )

  # The voltage analysis is a sensitivity check.
  # Remove only observations strictly above the empirical threshold
  # and stop after the first refinement to avoid over-cleaning.
  local_outliers <- which(
    t2_phase1 > empirical_ucl
  )

  if (length(local_outliers) == 0) {
    break
  }

  phase1_ids <- phase1_ids[
    -local_outliers
  ]

  break
}

phase1_clean <- phase1_ilr[
  phase1_ids,
  ,
  drop = FALSE
]

center <- colMeans(phase1_clean)
covariance <- cov(phase1_clean)

t2_reference <- mahalanobis(
  x = phase1_clean,
  center = center,
  cov = covariance
)

ucl <- unname(
  quantile(
    t2_reference,
    probs = 1 - alpha,
    type = 7
  )
)

# ------------------------------------------------------------
# 4. Monitor all cycles
# ------------------------------------------------------------

t2_all <- mahalanobis(
  x = ilr_voltage,
  center = center,
  cov = covariance
)

monitoring <- data.frame(
  cycle_id = voltage_data$cycle_id,
  T2 = as.numeric(t2_all),
  phase = ifelse(
    seq_len(nrow(voltage_data)) <= n_train,
    "Phase I",
    "Phase II"
  )
)

monitoring$out_of_control <- monitoring$T2 > ucl

# ------------------------------------------------------------
# 5. Plot
# ------------------------------------------------------------

dir.create(
  "results",
  recursive = TRUE,
  showWarnings = FALSE
)

p <- ggplot(
  monitoring,
  aes(
    x = cycle_id,
    y = T2
  )
) +
  geom_line(linewidth = 0.45) +
  geom_point(
    aes(shape = out_of_control),
    size = 1.7
  ) +
  geom_hline(
    yintercept = ucl,
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = monitoring$cycle_id[n_train],
    linetype = "dotdash"
  ) +
  labs(
    title = "Relative Voltage Monitoring — Sensitivity Analysis",
    x = "Cycle",
    y = expression(T[V]^2),
    shape = "Out of control"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  filename = file.path(
    "results",
    "voltage_control_chart.png"
  ),
  plot = p,
  width = 9.5,
  height = 5.2,
  dpi = 180
)

write.csv(
  monitoring %>%
    filter(
      phase == "Phase II",
      out_of_control
    ),
  file.path(
    "results",
    "voltage_phase2_alerts.csv"
  ),
  row.names = FALSE
)

cat(
  "Voltage sensitivity analysis complete.\n",
  "Empirical UCL:",
  round(ucl, 4),
  "\n"
)
