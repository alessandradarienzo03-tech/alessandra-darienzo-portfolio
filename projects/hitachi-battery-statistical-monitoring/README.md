# Hitachi Rail — Statistical Process Monitoring of Parallel Ni-Cd Batteries

**Compositional Data Analysis & Multivariate Statistical Process Control**

An industrial statistics project focused on detecting abnormal load
redistribution and degradation patterns in parallel-connected Nickel–Cadmium
batteries installed on a high-speed train.

The project was developed within the **Statistical Lab for Industrial Data
Analysis** at the University of Naples Federico II using Hitachi Rail battery
data.

> **Data note:** the original train-level data are industrial and are not
> redistributed in this repository. The public project contains cleaned
> methodology, analysis code, aggregate visualizations and a synthetic
> reproducibility example.

## Business / Engineering Question

Parallel batteries jointly supply auxiliary onboard systems. When the system
is healthy, their current contributions should remain reasonably balanced.

The difficulty is that the **total electrical load changes from cycle to
cycle**. Absolute current values can therefore move substantially even when
the battery system itself has not changed.

The project asks:

> **Can we detect abnormal battery behavior by monitoring how the total load is
> redistributed across the parallel batteries, rather than monitoring each
> current independently?**

## Data Structure

The analysis focuses on four parallel batteries:

- `C2`
- `C4`
- `C5`
- `C7`

The source data contain current and voltage measurements across repeated
charge/discharge groups. The exploratory analysis covers approximately
**200 discharge cycles**.

For each battery, power can also be derived as:

```text
Power = Current × Voltage
```

Because discharge current is approximately stable within an individual cycle,
the project summarizes each cycle using the **median current**, producing a
robust cycle-level indicator that reduces high-frequency noise.

## Why Standard Monitoring Is Not Enough

The total current varies because the external electrical demand changes over
time.

This creates a confounding effect:

```text
absolute battery current
    = battery condition
    + external load variation
```

A deterioration in one battery may therefore be hidden if the other
parallel-connected batteries compensate for it.

The key modelling decision is to move from **absolute currents** to **relative
current contributions**.

## Compositional Data Approach

For every discharge cycle, the four battery-current magnitudes are treated as
parts of a whole.

After closure, the resulting vector represents the share of the total current
carried by each battery:

```text
x = (C2, C4, C5, C7)
```

with:

```text
C2 + C4 + C5 + C7 = 1
```

This removes the scale effect of the external load and shifts the analysis
toward **relative load redistribution**.

Because compositions live in the simplex rather than ordinary Euclidean
space, classical multivariate statistics cannot be applied directly.

The project therefore uses an **Isometric Log-Ratio (ILR) transformation** to
map the four-part composition into three unconstrained Euclidean coordinates.

## Statistical Process Monitoring

The transformed observations are monitored with a compositional
**Hotelling-type T² control chart**.

The monitoring statistic is based on the Mahalanobis distance:

```text
T² = (z - μ)' Σ⁻¹ (z - μ)
```

where:

- `z` is the ILR-transformed composition;
- `μ` is the reference centre;
- `Σ` is the reference covariance matrix.

### Phase I — Reference Calibration

The early cycles are used to estimate an in-control reference state.

The public implementation uses a **70-cycle initial calibration window** and
supports iterative removal of out-of-control observations before finalizing
the baseline.

### Distributional Diagnostics

The project explicitly checks the assumptions behind the control chart using:

- Q–Q plots of ILR coordinates;
- Shapiro–Wilk tests;
- false-discovery-rate adjustment;
- Henze–Zirkler multivariate normality test;
- Mardia multivariate normality test.

The analyses indicate departures from multivariate normality.

For this reason, the monitoring workflow also considers an **empirical upper
control limit** estimated from the cleaned Phase I distribution rather than
relying exclusively on theoretical normality-based thresholds.

### Phase II — Monitoring

The remaining cycles are evaluated against the fixed Phase I reference.

A cycle is flagged when its compositional T² statistic exceeds the selected
control limit.

## Main Findings

The control-chart analysis identifies two important patterns:

### 1. Temporary anomalous regime

A cluster of abnormal observations appears approximately around
**cycles 70–110**.

The available project data do not contain maintenance labels sufficient to
determine the underlying cause, so this is interpreted as a temporary
out-of-control operating regime rather than a confirmed battery failure.

### 2. Persistent redistribution after approximately cycle 150

A more persistent change appears in the later part of the series.

The cycle-level current profiles indicate a redistribution of the load:

- **C4 and C5:** decreasing relative contribution;
- **C2 and C7:** compensating contribution.

This is the central engineering insight of the project: a battery system can
continue supplying the required total current while the internal distribution
of that load becomes increasingly unbalanced.

## Why the Compositional View Matters

Monitoring only total current can miss internal degradation.

A relatively stable total load can coexist with substantial changes in how
the four batteries share that load.

The compositional framework therefore provides a monitoring signal that is:

- largely independent of total external load;
- multivariate by construction;
- sensitive to relative imbalance;
- interpretable in terms of load redistribution.

## Voltage Sensitivity Analysis

Voltage is analysed as a complementary monitoring variable.

Because parallel-connected batteries should operate at similar voltage levels,
voltage deviations may help identify:

- measurement anomalies;
- changes in internal resistance;
- unusual operating conditions.

The project treats voltage monitoring as an extension rather than the primary
degradation indicator.

## Statistical & Quantitative Methods

This project combines:

- robust cycle-level aggregation;
- compositional data analysis (CoDa);
- closure transformation;
- Isometric Log-Ratio transformation;
- Mahalanobis distance;
- Hotelling-type T² statistics;
- multivariate statistical process control;
- iterative Phase I calibration;
- empirical control-limit estimation;
- multivariate normality testing;
- false-discovery-rate correction;
- signal diagnosis through component-level time-series analysis.

## Industrial Interpretation

The methodology is designed as an **early-warning condition-monitoring
framework**, not as a supervised failure classifier.

It can answer three progressively more useful questions:

1. **Detection** — Has the battery system departed from its reference state?
2. **Localization** — Which batteries are changing their relative
   contribution?
3. **Maintenance support** — Is the change persistent enough to justify
   inspection or increased monitoring?

Confirmed root-cause diagnosis would require integration with maintenance
records and operating-context variables.

## Repository Structure

```text
hitachi-battery-statistical-monitoring/
├── README.md
├── data/
│   └── README.md
├── R/
│   ├── README.md
│   ├── 01_cycle_level_feature_engineering.R
│   ├── 02_coda_t2_control_chart.R
│   ├── 03_voltage_sensitivity_analysis.R
│   └── 04_synthetic_reproducibility_demo.R
├── docs/
│   ├── methodology.md
│   └── references.md
└── results/
    ├── README.md
    ├── median_current_by_cycle.png
    ├── total_current_by_cycle.png
    ├── coda_t2_control_chart.png
    └── voltage_control_chart.png
```

## Technology Stack

**Language:** R  
**Data manipulation:** dplyr, tidyverse  
**Visualization:** ggplot2, patchwork  
**Compositional Data Analysis:** compositions, robCompositions  
**Statistical monitoring:** Hotelling T² / Mahalanobis distance  
**Diagnostics:** MVN, mvnormtest, Shapiro–Wilk, FDR correction

## Limitations

The analysis should be interpreted as statistical condition monitoring rather
than confirmed failure diagnosis.

Key limitations include:

- no complete maintenance-event labels for validating every anomaly;
- monitoring performed on a single train dataset;
- sensitivity of control limits to the selected reference period;
- operational context such as temperature and mission profile not yet
  integrated into the statistical model.

## Future Extensions

The original project identifies several natural next steps:

- integrate temperature and operating-condition variables;
- combine current and voltage evidence;
- connect characteristic redistribution patterns to specific failure modes;
- build an actionable battery-health index;
- link monitoring signals to maintenance priorities and risk thresholds.

## Key Takeaway

The project demonstrates a core principle of industrial statistics:

> **When multiple components jointly carry a varying total load, the most
> informative signal may be the change in their relative contributions rather
> than the change in their absolute values.**

By combining compositional geometry with multivariate statistical process
control, the analysis converts noisy train-level battery measurements into an
interpretable early-warning framework for industrial condition monitoring.
