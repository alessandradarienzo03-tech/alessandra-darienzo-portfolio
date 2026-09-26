# Methodology

## 1. Engineering Motivation

The monitored system consists of four Ni-Cd batteries connected in parallel
and supplying auxiliary systems on a high-speed train.

When the system is healthy, the batteries should contribute comparable shares
of the total electrical load.

The key complication is that the **external load changes across discharge
cycles**. Absolute current values therefore mix two effects:

```text
observed current
= external load level
+ internal load redistribution
```

This makes univariate monitoring of individual currents difficult to interpret.

## 2. Cycle-Level Aggregation

The raw data contain many high-frequency measurements within each
charge/discharge group.

Exploratory analysis showed that discharge current is approximately stable
within an individual cycle.

The project therefore summarizes each battery with the **median current per
cycle**, which provides a robust indicator and reduces sensitivity to
measurement noise.

For complementary analysis, median voltage and derived power are retained as
well.

## 3. Why Compositional Data Analysis

The four parallel batteries jointly carry the total discharge current.

For each cycle, their positive current magnitudes are converted into shares:

```text
x = (x_C2, x_C4, x_C5, x_C7)
```

with:

```text
x_C2 + x_C4 + x_C5 + x_C7 = 1
```

The monitoring target is therefore the **relative composition** of the total
current rather than its absolute level.

This removes the scale effect created by changes in the external electrical
load.

## 4. Closure and ILR Transformation

Compositional observations lie in the simplex, so ordinary Euclidean
multivariate methods cannot be applied directly to the raw shares.

The analysis first applies closure:

```text
C(x) = x / sum(x)
```

and then maps the four-part composition into three Euclidean coordinates using
the **Isometric Log-Ratio (ILR) transformation**.

The transformed vector is denoted:

```text
z = ilr(C(x))
```

## 5. Phase I Calibration

The final project implementation uses the first **70 cycles** as the initial
Phase I reference period.

Phase I is calibrated iteratively:

1. close the four-part current composition;
2. apply the ILR transformation;
3. estimate the multivariate centre and covariance matrix;
4. calculate the Hotelling-type statistic using Mahalanobis distance;
5. compare observations with the Phase I control limit;
6. remove out-of-control Phase I observations;
7. repeat until no additional Phase I signals remain.

The Phase I statistic is:

```text
T² = (z - μ)' Σ⁻¹ (z - μ)
```

The original final script computes the Phase I UCL from the Beta-distribution
formulation for individual multivariate observations.

## 6. Distributional Diagnostics

The cleaned Phase I ILR coordinates are evaluated using:

- Q-Q plots;
- Shapiro-Wilk tests on each coordinate;
- false-discovery-rate adjustment;
- Henze-Zirkler multivariate normality test;
- Mardia multivariate normality test.

The project found evidence against multivariate normality.

This motivated a more data-driven Phase II threshold.

## 7. Phase II Monitoring

The Phase I centre and covariance matrix are fixed and applied to all
subsequent cycles.

For each Phase II observation:

```text
T²_t = (z_t - μ_PhaseI)' Σ_PhaseI⁻¹ (z_t - μ_PhaseI)
```

The final project script uses an **empirical Phase II upper control limit**
estimated as the upper quantile of the cleaned Phase I T² distribution.

This avoids relying exclusively on a theoretical normality assumption that was
not supported by the diagnostics.

## 8. Signal Interpretation

The control chart is used first for **detection**.

The project then returns to the component-level current series to understand
which batteries drive the signal.

The final presentation highlights two regimes:

- approximately cycles 70–110: temporary abnormal behaviour;
- after approximately cycle 150: more persistent redistribution.

The component-level diagnosis suggests:

- C4 and C5 reduce their relative current contribution;
- C2 and C7 compensate by carrying more of the load.

The interpretation is therefore one of **load redistribution**, not simply a
drop in total current.

## 9. Voltage Sensitivity Analysis

Voltage is analysed as a complementary signal because parallel-connected
batteries should operate at similar voltage levels.

The project considers voltage deviations as potentially informative about:

- unusual operating conditions;
- internal-resistance changes;
- measurement anomalies.

Voltage monitoring is treated as an extension of the main current-based CoDa
framework.

## 10. Scope of the Analysis

The methodology is an **early-warning statistical process monitoring system**.

It does not claim to identify a definitive physical failure mode.

Root-cause validation would require additional evidence such as:

- maintenance logs;
- temperature measurements;
- mission profile;
- operating conditions;
- confirmed component replacement or inspection events.
