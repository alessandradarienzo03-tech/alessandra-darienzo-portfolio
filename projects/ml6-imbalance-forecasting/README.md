# Belgian Electricity Imbalance Forecasting

**ML6 Imbalance Forecasting Workshop**

A high-frequency forecasting project focused on predicting Belgian electricity
System Imbalance (SI) under real-time information constraints and translating
those forecasts into economically meaningful decisions.

## Project Objective

Belgium settles electricity imbalances every 15 minutes. Within each
quarter-hour, new information arrives continuously, making the prediction
problem dynamic: the information available at minute 1 is very different from
what is available at minute 14.

The objective of this project is to forecast the final quarter-hour System
Imbalance using only information that would genuinely be available at
prediction time.

The modelling pipeline combines:

- recent System Imbalance history;
- solar and wind generation forecasts;
- load forecasts;
- balancing volumes and prices;
- quarter-hour and calendar features;
- publication-delay-aware feature engineering.

A central design constraint is **strict prevention of data leakage**.

## Why It Matters

System Imbalance measures the mismatch between electricity generation and
consumption.

- **Positive SI** indicates excess generation.
- **Negative SI** indicates a shortage.
- Large imbalances can trigger costly balancing actions and create trading
  opportunities for market participants.

Because the workshop evaluates forecasts through an economic simulation as
well as predictive error, correctly identifying the **direction and magnitude
of large imbalance events** is especially important.

## Modelling Architecture

The core forecasting pipeline follows six stages:

1. **Leakage-aware data preparation**  
   Publication delays are explicitly modelled so that each feature reflects
   only information available at the prediction timestamp.

2. **Persistence benchmark**  
   A naive persistence model provides the baseline that more advanced models
   must outperform.

3. **Minute-specific forecasting**  
   Separate models are trained for each of the 15 minutes within a
   quarter-hour, reflecting the changing information set over time.

4. **Gradient-boosted models**  
   XGBoost and LightGBM are trained on lagged SI, rolling statistics,
   renewable/load forecasts, balancing-market variables and time features.

5. **Extreme-event modelling**  
   Sample reweighting and a two-stage architecture are used to improve
   behaviour during large imbalance events.

6. **Interpretation and ensembling**  
   SHAP analysis is used to understand feature importance and multiple models
   are blended to balance average and extreme-event performance.

## Core Results

Selected results from the original workshop run:

| Model | Test RMSE |
|---|---:|
| Persistence baseline | 78.24 MW |
| XGBoost | 62.50 MW |
| LightGBM | 62.49 MW |
| XGBoost + LightGBM ensemble | **62.27 MW** |

For the extreme-event-focused modelling stage:

- extreme-event classifier recall: **0.87** on the validation set for
  `|SI| > 300 MW`;
- two-stage + tuned-XGBoost blend overall test RMSE: **68.75 MW**;
- extreme-event test RMSE: **111.85 MW**;
- weighted test RMSE: **90.30 MW**.

The final architecture intentionally explores a trade-off between minimizing
average RMSE and improving behaviour on economically important large
imbalances.

## Feature Engineering

The model uses several feature families:

### System Imbalance
- delayed SI;
- cumulative SI;
- SI trend;
- rolling means;
- short-term lags;
- previous-quarter statistics.

### Renewable & Demand Forecasts
- solar forecast;
- wind forecast;
- load forecast;
- forecast-deviation features.

### Balancing-Market Signals
- aFRR up/down volumes;
- mFRR activation;
- net balancing volume;
- balancing-price spreads.

### Time Features
- minute within the quarter-hour;
- hour;
- month;
- weekend/holiday indicators;
- cyclical time-of-day representation.

## Leakage Prevention

The most important methodological rule is that the model must never use
information from the future.

Publication delays and lag operations are therefore applied before model
training so that the feature set reproduces the actual real-time information
environment.

This is particularly important in electricity forecasting, where even a small
timestamp mistake can produce unrealistically strong validation results.

## Economic Perspective

Forecast quality is not evaluated purely through average prediction error.

A model that correctly identifies the direction of a large imbalance can be
more economically valuable than one that produces slightly lower average
error but misses stressed periods.

The workshop therefore connects forecasting to:

- Balance Responsible Party decisions;
- balancing-market exposure;
- battery charging/discharging strategies;
- profit-oriented evaluation.

## Notebooks

| Notebook | Description |
|---|---|
| [`01_core_imbalance_forecasting.ipynb`](notebooks/01_core_imbalance_forecasting.ipynb) | Main forecasting pipeline: leakage-aware features, persistence baseline, XGBoost, LightGBM, ensembling, extreme-event modelling and SHAP |
| `02_economic_simulation_and_battery_steering.ipynb` | Economic simulation and battery-steering logic based on imbalance forecasts |

## Data

The original ML6 workshop datasets are **not redistributed** in this
repository.

The project uses time-series data covering:

- System Imbalance and ACE;
- solar generation and forecasts;
- wind generation and forecasts;
- balancing prices;
- balancing volumes;
- incremental and decremental bids;
- load forecasts.

To run the notebook locally, the original parquet files must be placed in a
local `data/` directory.

## Technology Stack

**Language:** Python  
**Data:** Pandas, NumPy  
**Machine Learning:** XGBoost, LightGBM, Scikit-learn  
**Explainability:** SHAP  
**Visualization:** Matplotlib, Seaborn  
**Domain:** Electricity markets, time-series forecasting, real-time decision support

## Repository Structure

```text
ml6-imbalance-forecasting/
├── README.md
├── notebooks/
│   ├── README.md
│   ├── 01_core_imbalance_forecasting.ipynb
│   └── 02_economic_simulation_and_battery_steering.ipynb
├── docs/
│   └── imbalance_forecasting_knowledge.md
└── results/
```

## Key Takeaways

This project demonstrates that high-frequency forecasting is not only a model
selection problem.

The strongest improvements came from combining:

- realistic information timing;
- careful leakage prevention;
- time-aware feature engineering;
- minute-specific models;
- ensemble methods;
- explicit treatment of rare but high-impact events.

The result is a forecasting pipeline designed around both predictive accuracy
and the economic consequences of forecast errors.

