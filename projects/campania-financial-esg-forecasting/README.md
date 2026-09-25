# Predictive Financial & ESG Analytics for Private Companies

An end-to-end machine learning framework for forecasting financial and
sustainability performance across private companies in Campania, Italy.

## Overview

This project investigates whether historical financial and ESG information
can be used to forecast private-company performance and support structured
comparison across heterogeneous firms.

The analysis was developed as part of an academic data science challenge at
the University of Naples Federico II.

> **Data note:** the original company-level dataset is proprietary and is not
> distributed in this repository. Public notebooks use synthetic examples,
> aggregate metrics and non-confidential results to reproduce the methodology.

## Research Paper

The complete methodology, experimental design and empirical results are
documented in the accompanying paper:

**Predictive and Explainable Forecasting of Financial and ESG Performance in
Private Companies: Evidence from Campania (2015–2024)**

[Read the research paper](paper/predictive-financial-esg-forecasting-paper.pdf)

## Project Highlights

- Started from **12,422 private companies** and **117 features**.
- Built a final modelling dataset of **7,660 companies** and **97 variables**.
- Forecast **Sales Revenue, EBITDA, Net Income and ESG performance**.
- Benchmarked **Linear Regression, Random Forest, XGBoost, Prophet and LSTM**.
- Selected **Random Forest** as the benchmark leader with **MSE = 0.00285**.
- Evaluated model performance across **firm size, geography and macro-sector**.
- Developed an **LLM + web-search workflow** to recover missing province data.
- Combined predicted **EBITDA and ESG** in an Economic–Sustainability
  Positioning Matrix for decision support.

## Analytical Workflow

| Step | Component | Public implementation |
|---:|---|---|
| 1 | Data-quality assessment and preprocessing | [Notebook 01](notebooks/01_data_quality_and_preprocessing.ipynb) |
| 2 | Business-driven company segmentation | [Notebook 02](notebooks/02_company_segmentation.ipynb) |
| 3 | Model benchmarking | [Notebook 03](notebooks/03_model_benchmarking.ipynb) |
| 4 | Financial and ESG forecasting | [Notebook 04](notebooks/04_financial_esg_forecasting.ipynb) |
| 5 | Cluster-level evaluation and business insights | [Notebook 05](notebooks/05_explainability_and_business_insights.ipynb) |
| 6 | GenAI-assisted geographic imputation | [Notebook 06](notebooks/06_genai_geographic_imputation.ipynb) |

## Dataset

The original dataset contains financial, geographic, employment and ESG
information for private companies located in Campania.

| Dataset stage | Companies | Features |
|---|---:|---:|
| Initial dataset | 12,422 | 117 |
| Final modelling dataset | 7,660 | 97 |

The financial variables span **2015–2024**, while ESG information is available
for **2019–2021**.

## Preprocessing

The pipeline includes:

1. normalization of missing-value representations;
2. financial plausibility checks;
3. percentile-based financial outlier treatment;
4. ESG winsorization;
5. company-level missingness filtering;
6. temporal interpolation;
7. business-driven company segmentation;
8. Robust Scaling followed by Min–Max Scaling.

## Model Benchmarking

| Model | MSE |
|---|---:|
| Random Forest | **0.00285** |
| LSTM | 0.00287 |
| XGBoost | 0.00292 |
| Linear Regression | 0.00299 |
| Prophet | 0.00392 |

Random Forest achieved the lowest benchmark error and was retained for the
subsequent target-specific forecasting analysis.

## Forecasting Targets

The selected model was applied to:

- **Sales Revenue 2024**
- **EBITDA 2024**
- **Net Income 2024**
- **ESG score 2021**

Financial forecasts use historical observations from 2015–2023. The ESG model
uses the available 2019–2020 history to forecast 2021.

## Company Segmentation

Results are interpreted across:

- company size;
- operational province;
- economic macro-sector;
- employment-growth class.

Employment dynamics are classified using three-year CAGR:

- **growing:** CAGR > +10%;
- **stable:** CAGR between −10% and +10%;
- **declining:** CAGR < −10%.

Reusable segmentation utilities are available in
[`src/segmentation.py`](src/segmentation.py).

## GenAI-Assisted Data Enrichment

The original dataset contained missing operational-province information for
**1,304 records**.

A web-search-assisted LLM workflow was developed using **Llama 3.1 via Groq**
and **DuckDuckGo**. Repeated retrieval, output validation and majority voting
were used to reduce dependence on a single generated answer.

See [Notebook 06](notebooks/06_genai_geographic_imputation.ipynb).

## Economic–Sustainability Positioning

Predicted EBITDA and ESG performance are combined in a two-dimensional
positioning matrix with median-based thresholds.

This creates four interpretable profiles:

- high economic / high sustainability;
- high economic / low sustainability;
- low economic / high sustainability;
- low economic / low sustainability.

Aggregate result visualizations are available in
[`results/`](results/).

## Technology Stack

**Core analytics:** Python, Pandas, NumPy, Scikit-learn  
**Machine learning:** Random Forest, XGBoost, Linear Regression  
**Deep learning & time series:** TensorFlow / Keras, LSTM, Prophet  
**Generative AI:** LangChain, LangGraph, Groq, Llama 3.1, DuckDuckGo Search  
**Visualization:** Matplotlib

## Repository Structure

```text
campania-financial-esg-forecasting/
├── README.md
├── requirements.txt
├── data/
│   └── README.md
├── notebooks/
│   ├── 01_data_quality_and_preprocessing.ipynb
│   ├── 02_company_segmentation.ipynb
│   ├── 03_model_benchmarking.ipynb
│   ├── 04_financial_esg_forecasting.ipynb
│   ├── 05_explainability_and_business_insights.ipynb
│   └── 06_genai_geographic_imputation.ipynb
├── src/
│   └── segmentation.py
├── results/
│   ├── README.md
│   ├── tables/
│   └── *.png
└── paper/
    ├── README.md
    └── predictive-financial-esg-forecasting-paper.pdf
```

## Reproducibility

Install the project dependencies with:

```bash
pip install -r requirements.txt
```

Live execution of the GenAI notebook additionally requires a valid
`GROQ_API_KEY`. No credentials are stored in the repository.

## Authors

Cristina Arino · Alessandra D'Arienzo · Lucio Di Gioia  
University of Naples Federico II
