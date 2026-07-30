# Predictive Financial & ESG Analytics for Private Companies

An end-to-end machine learning framework for forecasting financial and
sustainability performance across private companies in Campania, Italy.

## Overview

This project investigates whether historical financial and ESG information
can be used to forecast private-company performance and identify firms
combining economic strength with sustainability potential.

The analysis was developed as part of an academic data science challenge at
the University of Naples Federico II.

## Research Paper

The complete methodology, experimental design and results are documented in
the accompanying research paper:

[Read the research paper](paper/predictive-financial-esg-forecasting-paper.pdf)

## Project Highlights

- Processed an initial dataset of 12,422 private companies and 117 features.
- Built a final modelling dataset containing 7,660 companies and 97 variables.
- Forecast Sales Revenue, EBITDA, Net Income and ESG performance.
- Benchmarked Linear Regression, Random Forest, XGBoost, Prophet and LSTM.
- Selected Random Forest as the best-performing model with an MSE of 0.00285.
- Evaluated model performance across firm size, geography and macro-sector.
- Developed an LLM-assisted web-search workflow for missing geographic data.
- Designed an Economic–Sustainability Positioning Matrix for decision support.

## Business Question

Can historical financial and ESG data help anticipate private-company
performance and identify firms with both economic and sustainability
potential?

## Dataset

The original dataset included company-level financial, geographic,
employment and ESG information for private companies located in Campania.

| Dataset stage | Companies | Features |
|---|---:|---:|
| Initial dataset | 12,422 | 117 |
| Final modelling dataset | 7,660 | 97 |

The original company-level dataset is not included in this repository due
to confidentiality and licensing constraints.

## Methodology

The analytical pipeline includes:

1. data-quality assessment;
2. financial plausibility checks;
3. missing-value treatment;
4. outlier management;
5. business-driven company segmentation;
6. feature scaling;
7. model benchmarking;
8. financial and ESG forecasting;
9. cluster-level performance evaluation;
10. decision-oriented visualization.

## Model Benchmarking

| Model | MSE |
|---|---:|
| Random Forest | **0.00285** |
| LSTM | 0.00287 |
| XGBoost | 0.00292 |
| Linear Regression | 0.00299 |
| Prophet | 0.00392 |

Random Forest achieved the lowest benchmark error and was selected for the
subsequent forecasting and business analysis.

## Predicted Indicators

- Sales Revenue
- EBITDA
- Net Income
- ESG score

## Company Segmentation

Results were analyzed across:

- company size;
- operational province;
- economic macro-sector;
- employment growth class.

## GenAI-Assisted Data Enrichment

A web-search-assisted LLM workflow was developed to recover missing
operational-province information.

The workflow used iterative verification, output validation and majority
voting to reduce the risk of unsupported imputations.

## Economic–Sustainability Positioning

Predicted EBITDA and ESG performance were combined into a two-dimensional
positioning matrix to distinguish companies with balanced, asymmetric or
weak expected performance.

## Technology Stack

- Python
- Pandas
- NumPy
- Scikit-learn
- XGBoost
- TensorFlow / Keras
- Prophet
- LangChain
- LangGraph
- Groq
- Llama 3.1

## Repository Structure

```text
campania-financial-esg-forecasting/
├── README.md
├── notebooks/
├── src/
├── results/
├── data/
└── paper/
