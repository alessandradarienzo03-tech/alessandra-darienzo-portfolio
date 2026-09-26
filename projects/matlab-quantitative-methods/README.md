# MATLAB Quantitative Methods

**State Estimation & Mean–Variance Optimization**

This mini-portfolio contains two self-contained MATLAB studies that illustrate
core quantitative methods from control, statistics and optimization:

1. **Kalman Filter State Estimation** — recursive estimation in a noisy
   linear dynamical system;
2. **Markowitz Mean–Variance Optimization** — long-only portfolio allocation
   and efficient-frontier construction via quadratic programming.

The examples use synthetic inputs so that the repository is fully
reproducible and contains no proprietary data.

> These are intentionally compact methodological demonstrations rather than
> full end-to-end industry projects.

---

## 1. Kalman Filter State Estimation

[`matlab/kalman_filter_state_estimation.m`](matlab/kalman_filter_state_estimation.m)

The script simulates a two-state discrete-time linear system:

```text
x(k+1) = A x(k) + B u(k) + w(k)
y(k)   = H x(k) + v(k)
```

where:

- `w(k)` is zero-mean Gaussian process noise with covariance `Q`;
- `v(k)` is zero-mean Gaussian measurement noise with covariance `R`;
- only the first state is measured directly.

The Kalman filter is implemented explicitly through the two canonical stages.

### Prediction

```text
x̂(k|k-1) = A x̂(k-1|k-1) + B u(k-1)

P(k|k-1) = A P(k-1|k-1) A' + Q
```

### Measurement update

```text
ν(k) = y(k) - H x̂(k|k-1)

S(k) = H P(k|k-1) H' + R

K(k) = P(k|k-1) H' S(k)^(-1)

x̂(k|k) = x̂(k|k-1) + K(k)ν(k)
```

The covariance update uses the **Joseph form**:

```text
P(k|k) =
(I - KH) P(k|k-1) (I - KH)' + K R K'
```

which is numerically more robust than the simplest covariance subtraction
formula.

### Outputs

The script reports:

- filtered-state RMSE;
- open-loop RMSE for comparison;
- innovation statistics;
- time-series plots of true, measured and estimated states;
- estimation-error plots with ±2σ uncertainty bands.

The implementation is written directly from the Kalman equations and does
**not** require the Control System Toolbox.

---

## 2. Markowitz Mean–Variance Optimization

[`matlab/markowitz_mean_variance_optimization.m`](matlab/markowitz_mean_variance_optimization.m)

The second study constructs a long-only Markowitz efficient frontier.

For portfolio weights `w`, expected returns `μ` and covariance matrix `Σ`,
portfolio return and variance are:

```text
E[r_p] = μ' w

Var(r_p) = w' Σ w
```

For each target return, the script solves:

```text
minimize      w' Σ w

subject to    1' w = 1
              μ' w = R_target
              w >= 0
```

This is a convex quadratic program and is solved with MATLAB `quadprog`.

The script also computes:

- the **global minimum-variance portfolio**;
- an **equal-weight benchmark**;
- the maximum-Sharpe portfolio available on the discretized frontier;
- asset weights along the efficient frontier.

### Outputs

The script produces:

- efficient-frontier visualization;
- portfolio-allocation evolution along the frontier;
- console summaries of expected return, volatility and weights.

The numerical inputs are synthetic and are included only to demonstrate the
optimization methodology. They are not investment recommendations.

---

## Repository Structure

```text
matlab-quantitative-methods/
├── README.md
├── matlab/
│   ├── kalman_filter_state_estimation.m
│   └── markowitz_mean_variance_optimization.m
└── results/
    └── generated automatically when the scripts are run
```

---

## Requirements

### Kalman Filter

- MATLAB
- no additional toolbox required

### Markowitz Optimization

- MATLAB
- Optimization Toolbox (`quadprog`)

The scripts use `exportgraphics`, available in recent MATLAB releases.

---

## Reproducibility

Both scripts:

- use explicit random seeds where simulation is involved;
- define all numerical assumptions inside the file;
- validate key inputs;
- create a local `results/` folder automatically;
- save publication-ready figures;
- print concise quantitative summaries to the MATLAB command window.

---

## Key Takeaway

Although the two examples come from different application domains, they
illustrate two complementary quantitative ideas:

```text
Kalman filtering
→ infer hidden system states from noisy sequential measurements

Markowitz optimization
→ allocate decision variables under risk–return constraints
```

Together they provide compact examples of **recursive statistical estimation**
and **constrained numerical optimization** in MATLAB.
