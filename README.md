# Alessandra D'Arienzo

### Data Science · Statistical Learning · Machine Learning · Quantitative Research

**Forecasting, statistical modelling and AI for economic, energy and industrial systems.**

I am a Master's student in **Management Engineering — Data Science** at the
**University of Naples Federico II**, with international academic experience
in **Computer Science at KU Leuven**.

My work sits at the intersection of **statistics, machine learning, economic
modelling and decision systems**. I am especially interested in problems where
data are noisy, incomplete or time-dependent — and where the objective is not
only to predict accurately, but to produce evidence that can support a real
decision.

Across this portfolio, I work on financial and ESG forecasting, electricity
imbalance prediction, multivariate statistical process monitoring,
reinforcement learning and nonlinear control, industrial optimization,
physics-informed machine learning, Generative AI and symbolic reasoning.

> **The common thread is decision-making under uncertainty:** understand the
> system, model it rigorously, validate it honestly, and translate the result
> into something useful.

My longer-term research interests are particularly connected to
**macroeconomic and financial statistics, central banking, forecasting and
nowcasting, economic and energy systems, trustworthy AI, and quantitative
research in public-interest institutions**.

---

## Selected Research & Technical Projects

| Project | Focus | Methods | Selected result |
|---|---|---|---|
| **[Predictive Financial & ESG Analytics](projects/campania-financial-esg-forecasting/)** | Private-company financial and sustainability forecasting | Random Forest, XGBoost, LSTM, Prophet, explainability, GenAI-assisted data enrichment | 12,422 firms analysed; Random Forest benchmark MSE **0.00285**; research paper included |
| **[Belgian Electricity Imbalance Forecasting](projects/ml6-imbalance-forecasting/)** | High-frequency forecasting for the Belgian balancing market | Leakage-aware time series, XGBoost, LightGBM, ensembles, SHAP, extreme-event modelling | Ensemble RMSE **62.27 MW** vs **78.24 MW** persistence; extreme-event classifier recall **0.87** |
| **[Hitachi Rail Battery Statistical Monitoring](projects/hitachi-battery-statistical-monitoring/)** | Early-warning monitoring of parallel Ni-Cd batteries | Compositional Data Analysis, ILR, Mahalanobis distance, Hotelling-type T², Phase I/II SPC | Detects internal load redistribution while separating it from changing total electrical load |
| **[Reinforcement Learning & Nonlinear MPC for a Dynamic Duopoly](projects/oligopoly-rl-nmpc-control/)** | Economic production control under time-varying demand | DQN, nonlinear ODEs, reward shaping, NMPC, SQP, receding-horizon optimization | Simulation benchmark: DQN average firm-1 profit **0.360** vs **0.227** uncontrolled |

These four projects best represent the quantitative core of my portfolio:
**forecasting, statistical inference, economic modelling, optimization and
learning-based decision systems**.

---

## More Applied Work

### [Physics-Informed Vibration Fault Detection](projects/gdg-vibration-fault-detection/)

Structural-condition classification from three-axis accelerometer data using
FFT analysis, physics-informed spectral features and leakage-aware validation.

The project explicitly stress-tests generalization across **replicates, unseen
sensor boards and unseen excitation patterns** rather than relying on a naive
random split. Random Forest reaches **0.930 accuracy on unseen boards**, while
the most demanding combined holdout reveals the true out-of-distribution
limits of the model.

**Methods:** signal processing · FFT · Logistic Regression · Random Forest ·
LightGBM · feature importance · grouped validation

---

### [Ferrero Production Line Optimization & Predictive Maintenance](projects/ferrero-production-line-optimization/)

Industrial analytics project for a Kinder Bueno Eggs production line,
combining bottleneck diagnosis, OEE, integer optimization, buffer logic and a
predictive-maintenance proof of concept.

The analysis identifies **Secondary Packaging as the bottleneck** and finds a
minimum-capacity rebalancing solution of **+1 Primary Packaging machine and +2
Secondary Packaging machines**.

**Methods:** throughput modelling · cycle-time analysis · integer optimization
· OEE · predictive maintenance · MATLAB

---

### [POSE — AI-Powered Privacy Policy Intelligence](projects/pose-ai-privacy-assistant/)

A Generative AI prototype that converts long privacy policies into structured,
evidence-aware and personalized Privacy Snapshots.

The implementation separates the **LLM extraction layer** from a deterministic
privacy-preference scoring layer, using **Gemini, Pydantic and Gradio**.

**Methods:** structured LLM output · schema validation · prompt engineering ·
rule-based personalization · human-centered AI

---

### [Symbolic AI & Constraint Reasoning](projects/symbolic-ai-constraint-reasoning/)

Two formal-reasoning case studies developed with **IDP3 / FO(·) / Linear Time
Calculus**, covering static constraint modelling and dynamic temporal systems.

Topics include **model expansion, recursive reachability, satisfiability,
minimal-unsatisfiable configurations, optimization, counterexample generation
and non-deterministic state transitions**.

**Methods:** symbolic AI · first-order logic · automated reasoning · temporal
logic · constraint modelling

---

### [MATLAB Quantitative Methods](projects/matlab-quantitative-methods/)

Compact implementations of two classical quantitative methods:

- **Kalman filtering** for recursive state estimation under process and
  measurement uncertainty;
- **Markowitz mean–variance optimization** for constrained portfolio allocation
  and efficient-frontier construction.

**Methods:** state-space estimation · uncertainty propagation · quadratic
programming · numerical optimization

---

## Project Map

| Research / application area | Projects |
|---|---|
| **Economic & financial analytics** | Campania Financial & ESG Forecasting · Dynamic Oligopoly RL/NMPC · Markowitz Optimization |
| **Energy systems & markets** | Belgian Electricity Imbalance Forecasting |
| **Statistics & condition monitoring** | Hitachi Rail Battery Monitoring · Kalman Filtering |
| **Industrial AI & operations** | Ferrero Production Optimization · Vibration Fault Detection |
| **Generative & trustworthy AI** | POSE Privacy Intelligence |
| **Symbolic AI & formal reasoning** | Masyu & Sokoban reasoning case studies |

---

## Research Interests

I am particularly interested in applying quantitative methods to questions
with **economic, institutional or societal relevance**, including:

- macroeconomic and financial statistics;
- central banking and monetary / financial data;
- forecasting and nowcasting under real-time information constraints;
- time-series and panel-data modelling;
- statistical learning and explainable machine learning;
- economic and energy-system modelling;
- optimization, control and reinforcement learning;
- trustworthy, interpretable and human-centered AI.

I am especially drawn to research-intensive environments where modelling
choices must be **methodologically defensible, reproducible and useful for
decision-making**.

---

## How I Work

A few principles recur across the projects in this repository:

**Start from the problem, not the algorithm.**  
The model should follow the structure of the system and the decision it is
supposed to support.

**Treat validation as part of the research question.**  
I pay particular attention to temporal leakage, grouped splits,
out-of-distribution testing, benchmark selection and the limits of the
available evidence.

**Prefer interpretable structure where it matters.**  
Examples include compositional transformations for battery monitoring,
physics-informed spectral features for vibration analysis and deterministic
post-processing around LLM outputs.

**Report limitations explicitly.**  
A strong model is not one that hides uncertainty; it is one whose conclusions
remain credible once assumptions and failure modes are made visible.

---

## Technical Toolkit

| Area | Tools & methods |
|---|---|
| **Programming** | Python · R · MATLAB · SQL |
| **Data & statistics** | Pandas · NumPy · statistical inference · time series · feature engineering · multivariate analysis · SPC |
| **Machine learning** | Scikit-learn · Random Forest · XGBoost · LightGBM · regression · model selection · hyperparameter tuning |
| **Deep learning & RL** | TensorFlow / Keras · LSTM · DQN · reinforcement learning |
| **Optimization & control** | NMPC · `fmincon` · `quadprog` · integer optimization · Kalman filtering |
| **Generative AI** | Gemini · Llama / Groq · Pydantic · Gradio · LangChain · LangGraph |
| **Visualization & explainability** | Matplotlib · SHAP · diagnostic and statistical visualization |
| **Formal reasoning** | IDP3 · FO(·) · Linear Time Calculus |

---

## Repository Philosophy

Each major project is documented as a small research case study and, where
possible, includes:

- the problem formulation and domain context;
- modelling assumptions and methodological choices;
- cleaned and reproducible code;
- benchmark comparisons;
- results and visualizations;
- limitations and next steps.

Industrial or proprietary datasets are **not redistributed**. Where necessary,
the repository contains cleaned public implementations, aggregate results or
synthetic reproducibility examples.

---

## About Me

I am completing my MSc in **Management Engineering — Data Science** at the
**University of Naples Federico II** and have studied Computer Science as an
exchange student at **KU Leuven**.

I am interested in **Data Science, Statistics, Machine Learning and
Quantitative Research**, particularly in teams working on complex economic,
financial, energy or public-interest problems.

A central motivation behind my work is the idea that rigorous quantitative
methods can help institutions turn complex signals into **better evidence,
better decisions and better policy**.

---

## Contact

**Alessandra D'Arienzo**

[LinkedIn](https://www.linkedin.com/in/alessandra-d-arienzo-706045240)  
[Email](mailto:alessandradarienzo03@gmail.com)
