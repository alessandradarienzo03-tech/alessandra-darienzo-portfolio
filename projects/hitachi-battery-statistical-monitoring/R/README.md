# R Analysis

This folder contains the cleaned public implementation of the statistical
workflow developed for the Hitachi Rail battery-monitoring project.

The original industrial dataset is not redistributed. The scripts expect a
local RDS file with the original variable structure.

## Scripts

| File | Purpose |
|---|---|
| [`01_cycle_level_feature_engineering.R`](01_cycle_level_feature_engineering.R) | Converts high-frequency battery measurements into robust cycle-level current, voltage and power features |
| [`02_coda_t2_control_chart.R`](02_coda_t2_control_chart.R) | Implements the main compositional Phase I / Phase II monitoring workflow using ILR coordinates and a Hotelling-type T² statistic |
| [`03_voltage_sensitivity_analysis.R`](03_voltage_sensitivity_analysis.R) | Applies the same relative multivariate monitoring logic to battery voltages as a complementary sensitivity analysis |

## Main Packages

```r
install.packages(c(
  "dplyr",
  "tidyr",
  "ggplot2",
  "compositions",
  "robCompositions",
  "MVN"
))
```

## Data

Place the original train-level RDS file locally and set:

```r
Sys.setenv(HITACHI_DATA = "data/Fleet_1_train_1.rds")
```

The first script creates:

```text
data/derived/cycle_level_features.rds
```

The remaining scripts use that cycle-level file.

## Methodological Notes

Discharge currents are negative in the source data by sign convention.
For compositional monitoring, the analysis uses their **absolute magnitudes**
so that each battery contribution can be interpreted as a positive share of
the total discharge current.

The main control-chart workflow follows the final project design:

- 70 initial cycles for Phase I calibration;
- iterative removal of Phase I out-of-control observations;
- closure of the four battery contributions;
- ILR transformation from the simplex to Euclidean coordinates;
- Mahalanobis / Hotelling-type T² monitoring;
- normality diagnostics on the cleaned Phase I coordinates;
- empirical Phase II upper control limit estimated from the cleaned
  Phase I T² distribution.

The scripts are written for transparency and reproducibility rather than as a
production battery-management system.
