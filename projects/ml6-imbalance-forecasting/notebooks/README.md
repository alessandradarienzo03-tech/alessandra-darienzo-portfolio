# Notebooks

This folder contains the main technical notebooks developed for the ML6
Electricity Imbalance Forecasting project.

The notebooks document the forecasting pipeline, feature engineering,
model evaluation and economic simulation developed during the workshop.

## Available Notebooks

| Notebook | Description | Status |
|---|---|---|
| [`01_core_imbalance_forecasting.ipynb`](01_core_imbalance_forecasting.ipynb) | Core forecasting pipeline including leakage-aware feature engineering, persistence baseline, XGBoost, LightGBM, ensembling, extreme-event modelling and SHAP-based interpretation | Available |
| `02_economic_simulation_and_battery_steering.ipynb` | Economic simulation translating imbalance forecasts into battery-steering decisions and profit-oriented evaluation | Coming next |

## Modelling Focus

The core forecasting notebook explores:

- publication-delay-aware feature engineering;
- quarter-hour and minute-level forecasting;
- persistence benchmarking;
- XGBoost and LightGBM models;
- one-model-per-minute architecture;
- ensemble forecasting;
- volatility-aware sample reweighting;
- extreme-imbalance classification;
- two-stage modelling;
- SHAP-based feature interpretation.

## Data

The original ML6 workshop datasets are not redistributed in this repository.

To run the notebooks locally, the original parquet datasets must be placed
inside a local `data/` directory.

## Reproducibility

The public notebooks are designed to document the complete modelling logic
while excluding private workshop infrastructure, submission endpoints and
restricted datasets.
