# Imbalance Forecasting — Knowledge Notes

This document summarizes the domain knowledge used to frame the ML6
Imbalance Forecasting Workshop.

It follows the original workshop structure:

1. problem understanding;
2. market players and incentives;
3. System Imbalance forecasting and model architecture.

---

## 1. Understanding the Problem

### 1.1 Why the grid must stay balanced

Electricity generation and consumption must remain closely balanced in real
time. Deviations affect grid frequency and can create operational stress.

The forecasting problem therefore sits at the intersection of:

- physical grid stability;
- renewable-generation uncertainty;
- electricity-market incentives;
- real-time balancing actions.

### 1.2 System Imbalance

System Imbalance (SI) measures the balance between electricity generation and
consumption and is expressed in MW.

- **SI > 0:** excess generation;
- **SI < 0:** generation shortage;
- **SI = 0:** perfect balance.

In the workshop material, SI is treated as the central target for short-term
forecasting and economic decision-making.

A simplified representation is:

```text
SI = ΔP + kΔf − (aFRR_req + mFRR_req)
```

where the terms capture deviations in scheduled flows, frequency-control error
and activated balancing reserves.

### 1.3 Why forecasting is difficult

The workshop identifies several sources of uncertainty:

- variable solar generation;
- variable wind generation;
- demand uncertainty;
- cross-border power flows;
- market-participant behaviour;
- feedback from balancing-reserve activation.

As renewable penetration increases, short-term imbalance dynamics become more
volatile and harder to predict.

---

## 2. Market Players and Incentives

### 2.1 TSO — Transmission System Operator

In Belgium, Elia is responsible for maintaining physical grid stability.

Relevant objectives include:

- maintaining system balance;
- managing reserves;
- limiting balancing costs;
- coordinating real-time system operation.

An SI forecast can support more proactive balancing decisions.

### 2.2 BRP — Balance Responsible Party

A BRP is financially responsible for deviations between its scheduled and
realized portfolio position.

Its incentives include:

- reducing portfolio imbalance;
- improving load and generation forecasts;
- adjusting positions through day-ahead and intraday trading.

For a BRP, predicting the sign and magnitude of System Imbalance can influence
trading and balancing decisions.

### 2.3 BSP — Balancing Service Provider

BSPs provide flexible resources that can respond to balancing needs.

Examples include:

- gas plants;
- batteries;
- industrial demand response;
- pumped hydro.

Forecasts can help BSPs anticipate when upward or downward flexibility may be
valuable.

### 2.4 NEMO — Nominated Electricity Market Operator

NEMOs operate electricity trading platforms such as the day-ahead and
intraday markets.

These markets allow participants to adjust positions before real-time
delivery.

### 2.5 BRP vs BSP

The workshop distinguishes the two roles:

| BRP | BSP |
|---|---|
| Commercial / financial | Physical / technical |
| Manages portfolio balance | Delivers flexibility |
| Uses forecasting and trading | Uses engineering and operations |
| Interacts through imbalance settlement | Interacts through balancing bids |

### 2.6 European dimension

Belgium is connected to the wider European electricity system.

Cross-border flows and European balancing mechanisms mean that Belgian
imbalance dynamics are influenced by neighbouring markets and interconnected
system conditions.

---

## 3. System Imbalance Forecasting

### 3.1 Time structure

Belgian imbalance settlement is organized in 15-minute periods.

Within each quarter hour, additional information becomes available over time.
This creates a changing forecasting problem:

- early in the quarter hour, only limited real-time information is available;
- later in the quarter hour, cumulative SI signals provide a stronger view of
  the final quarter-hour outcome.

This motivates minute-specific modelling.

### 3.2 Data used in the workshop

The workshop material lists the following ML6 datasets:

| Dataset | Main content | Role |
|---|---|---|
| `df_hist_15_min_imbalance_prices` | SI, ACE, alpha | Target and price signals |
| `df_hist_15_min_solar_power_generation` | Measured and forecast solar | Renewable driver |
| `df_hist_15_min_wind_power_generation` | Measured and forecast wind | Renewable driver |
| `df_hist_15_min_balancing_prices` | aFRR and mFRR prices | Market-stress signals |
| `df_hist_15_min_balancing_volumes` | Activated reserve volumes | Balancing activity |
| `df_hist_15_min_incremental_bids` | Upward balancing bids | Upward flexibility |
| `df_hist_15_min_decremental_bids` | Downward balancing bids | Downward flexibility |
| `df_hist_15_min_load_forecast` | Expected consumption | Demand-side driver |

The workshop also highlights potentially useful external information such as
generation by fuel type, cross-border flows, weather data and market prices.

### 3.3 Forecasting inputs

The conceptual feature set includes:

- recent SI values and lags;
- current renewable production;
- future solar and wind forecasts;
- load forecasts;
- hour of day;
- day of week;
- month / seasonal information.

### 3.4 Critical rule: no data leakage

A central rule of the project is that the model must never use information
that would not have been available at prediction time.

Lagging and publication-delay handling are therefore essential.

A model that accidentally uses future information can look excellent in
validation while failing in real operation.

---

## 4. Modelling Progression

The workshop frames model development as a sequence:

| Stage | Model / idea | Purpose |
|---|---|---|
| 1 | Persistence baseline | Establish a strong naive benchmark |
| 2 | Linear Regression | Learn linear feature relationships |
| 3 | XGBoost | Capture non-linear interactions |
| 4 | Advanced models / ensembles | Improve temporal and extreme-event behaviour |

The final public notebook extends this progression with LightGBM, model
ensembling, sample reweighting, two-stage extreme-event modelling and SHAP
interpretation.

---

## 5. Economic Evaluation

Forecasts are not evaluated only by statistical error.

The workshop connects SI forecasts to trading and battery-steering decisions:

- expected shortage → take a long / discharge-oriented position;
- expected surplus → take a short / charge-oriented position.

This means that the value of a forecast depends not only on its average error
but also on whether it correctly identifies large and economically important
imbalances.

The workshop therefore emphasizes:

- persistence as the benchmark;
- lag features;
- renewable and load forecasts;
- time features;
- strict leakage prevention;
- profit-aware evaluation.

---

## 6. Portfolio Connection

The technical implementation is available in:

- [`../notebooks/01_core_imbalance_forecasting.ipynb`](../notebooks/01_core_imbalance_forecasting.ipynb)
- [`../notebooks/02_economic_simulation_and_battery_steering.ipynb`](../notebooks/02_economic_simulation_and_battery_steering.ipynb)

The first notebook focuses on high-frequency forecasting.

The second connects forecasts to battery steering and BRP settlement impact.
