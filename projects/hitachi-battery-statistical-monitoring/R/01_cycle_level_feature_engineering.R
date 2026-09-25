# ============================================================
# Hitachi Rail Battery Monitoring
# 01 - Cycle-Level Feature Engineering
# ============================================================
#
# Purpose
# -------
# Convert high-frequency measurements from four parallel Ni-Cd batteries
# into robust cycle-level indicators.
#
# The original project observed that discharge current is approximately
# stable within a cycle. Median aggregation is therefore used to reduce
# high-frequency noise before statistical process monitoring.
#
# The industrial source data are not included in the public repository.
# ============================================================

required_packages <- c("dplyr", "tidyr", "ggplot2")

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
library(tidyr)
library(ggplot2)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

data_path <- Sys.getenv(
  "HITACHI_DATA",
  unset = "data/Fleet_1_train_1.rds"
)

if (!file.exists(data_path)) {
  stop(
    "Industrial source data not found at: ", data_path, "\n",
    "Set the HITACHI_DATA environment variable to the local RDS path."
  )
}

df <- readRDS(data_path)

# ------------------------------------------------------------
# 2. Validate expected structure
# ------------------------------------------------------------

battery_ids <- c("C2", "C4", "C5", "C7")

current_cols <- paste0("IBatt_", battery_ids)
voltage_cols <- paste0("VBatt_", battery_ids)
phase_cols   <- paste0("ID_Ph_", battery_ids)

required_cols <- c(
  "ID_GR",
  current_cols,
  voltage_cols
)

missing_cols <- setdiff(required_cols, names(df))

if (length(missing_cols) > 0) {
  stop(
    "Missing expected columns: ",
    paste(missing_cols, collapse = ", ")
  )
}

# ------------------------------------------------------------
# 3. Basic type cleaning
# ------------------------------------------------------------

if ("Vehicle" %in% names(df)) {
  df$Vehicle <- factor(df$Vehicle)
}

if ("POC_ID" %in% names(df)) {
  df$POC_ID <- factor(df$POC_ID)
}

df$ID_GR <- factor(df$ID_GR)

for (col in intersect(phase_cols, names(df))) {
  df[[col]] <- factor(df[[col]], levels = c("S", "C"))
}

# ------------------------------------------------------------
# 4. Derived electrical quantities
# ------------------------------------------------------------
#
# Source convention:
#   negative current -> battery discharging
#   positive current -> battery charging
#
# Power is retained with its original sign.
# Absolute current magnitude is added separately for the
# compositional monitoring stage.

for (id in battery_ids) {
  current_col <- paste0("IBatt_", id)
  voltage_col <- paste0("VBatt_", id)
  power_col   <- paste0("PBatt_", id)
  abs_col     <- paste0("Iabs_", id)

  df[[power_col]] <- df[[current_col]] * df[[voltage_col]]
  df[[abs_col]]   <- abs(df[[current_col]])
}

# ------------------------------------------------------------
# 5. Robust aggregation by charge/discharge group
# ------------------------------------------------------------

numeric_features <- c(
  current_cols,
  voltage_cols,
  paste0("PBatt_", battery_ids),
  paste0("Iabs_", battery_ids)
)

metadata_features <- intersect(
  c("POC_ID", "Vehicle"),
  names(df)
)

cycle_level <- df %>%
  group_by(ID_GR) %>%
  summarise(
    across(
      all_of(numeric_features),
      ~ median(.x, na.rm = TRUE)
    ),
    across(
      all_of(metadata_features),
      ~ dplyr::first(.x)
    ),
    n_measurements = dplyr::n(),
    .groups = "drop"
  )

# Preserve cycle order numerically where possible.
cycle_level <- cycle_level %>%
  mutate(
    cycle_id = suppressWarnings(
      as.integer(as.character(ID_GR))
    )
  )

if (all(!is.na(cycle_level$cycle_id))) {
  cycle_level <- cycle_level %>%
    arrange(cycle_id)
} else {
  cycle_level <- cycle_level %>%
    mutate(cycle_id = row_number())
}

# ------------------------------------------------------------
# 6. Quality checks
# ------------------------------------------------------------

if (anyNA(cycle_level[paste0("Iabs_", battery_ids)])) {
  warning(
    "Some cycle-level current magnitudes are missing. ",
    "Inspect the corresponding source cycles before CoDa monitoring."
  )
}

if (any(
  as.matrix(cycle_level[paste0("Iabs_", battery_ids)]) <= 0,
  na.rm = TRUE
)) {
  warning(
    "At least one cycle has a non-positive median discharge-current ",
    "magnitude. Such rows cannot be used directly in log-ratio analysis."
  )
}

# ------------------------------------------------------------
# 7. Save derived cycle-level dataset
# ------------------------------------------------------------

output_dir <- file.path("data", "derived")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

output_path <- file.path(
  output_dir,
  "cycle_level_features.rds"
)

saveRDS(cycle_level, output_path)

cat(
  "Saved", nrow(cycle_level),
  "cycle-level observations to", output_path, "\n"
)

# ------------------------------------------------------------
# 8. Public diagnostic plot
# ------------------------------------------------------------

plot_dir <- "results"
dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

current_long <- cycle_level %>%
  select(
    cycle_id,
    all_of(paste0("Iabs_", battery_ids))
  ) %>%
  pivot_longer(
    cols = -cycle_id,
    names_to = "battery",
    values_to = "median_current_magnitude"
  ) %>%
  mutate(
    battery = sub("^Iabs_", "", battery)
  )

p <- ggplot(
  current_long,
  aes(
    x = cycle_id,
    y = median_current_magnitude,
    group = battery,
    linetype = battery
  )
) +
  geom_line(linewidth = 0.6) +
  labs(
    title = "Median Discharge-Current Magnitude by Cycle",
    x = "Cycle",
    y = "Median |current|",
    linetype = "Battery"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  filename = file.path(
    plot_dir,
    "median_current_by_cycle.png"
  ),
  plot = p,
  width = 9,
  height = 5,
  dpi = 180
)

# Total cycle-level discharge-current magnitude.
total_current <- cycle_level %>%
  transmute(
    cycle_id,
    total_median_current = rowSums(
      across(
        all_of(paste0("Iabs_", battery_ids))
      ),
      na.rm = TRUE
    )
  )

p_total <- ggplot(
  total_current,
  aes(
    x = cycle_id,
    y = total_median_current
  )
) +
  geom_line(linewidth = 0.7) +
  labs(
    title = "Total Median Discharge-Current Magnitude",
    x = "Cycle",
    y = "Total median |current|"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  filename = file.path(
    plot_dir,
    "total_current_by_cycle.png"
  ),
  plot = p_total,
  width = 9,
  height = 4.5,
  dpi = 180
)
