# Physics-Informed Vibration Fault Detection

**GDG KU Leuven**

A condition-monitoring project for detecting structural mounting faults from
three-axis vibration signals.

The project combines **signal processing**, **physics-informed feature
engineering**, **leakage-aware machine-learning validation**, and
**out-of-distribution generalization analysis**.

> **Important scope note:** the implementation contained in the Team 8
> notebook is a vibration-based bolt-condition classification project
> (`30NM`, `Loose`, `Mix-45°`). It is therefore documented here as a
> structural fault-detection project, not as an LED-degradation model.

## Problem

The objective is to determine whether the mechanical condition of a fixture
can be inferred from its vibration response.

Three structural conditions are considered:

- **30NM** — healthy / correctly tightened mounting;
- **Loose** — fully loosened mounting condition;
- **Mix-45°** — intermediate / mixed bolt condition.

Each test is observed through multiple accelerometer boards and three axes
(`X`, `Y`, `Z`) while the fixture is excited over controlled frequency bands.

The central question is:

> Can we identify a physically meaningful vibration signature of bolt
> loosening that generalizes across repeated tests, unseen sensor boards, and
> unseen excitation patterns?

## Dataset

The original dataset contains:

- **6,004 vibration recordings** after feature extraction;
- **15 sensor boards**;
- **5 replicates** for repeated test conditions;
- multiple excitation patterns;
- three accelerometer axes;
- sampling frequency of **27 kHz**;
- 8,192 samples per vibration recording.

Raw experimental files are not redistributed in this portfolio.

## 1. Physics Before Machine Learning

The analysis starts with direct inspection of the raw time signals and FFT
spectra.

A key preprocessing issue appears immediately on the Z axis: the vertical
accelerometer contains a strong DC gravity component.

The corrected spectral pipeline therefore applies:

1. mean subtraction to remove DC bias;
2. Hann windowing to reduce spectral leakage;
3. FFT computation;
4. magnitude normalization to support cross-condition comparison.

After correction, the loose-bolt condition shows sharper and stronger
resonance peaks across all three axes.

Representative peaks identified in the analysis include:

- X: approximately 168, 396, 573 and 728 Hz;
- Y: approximately 396, 570 and 728 Hz;
- Z: approximately 129, 233, 386 and 570 Hz.

These observations motivate the downstream feature engineering.

## 2. Physics-Informed Feature Engineering

Each recording is converted into a 36-dimensional feature vector.

For each of the three axes:

- energy in 10 frequency bands from 0 to 4 kHz;
- spectral centroid;
- RMS amplitude.

This gives:

```text
3 axes × 12 features = 36 features
```

The features are deliberately chosen from the physics of structural vibration
rather than generated blindly.

## 3. Excitation Sensitivity

A logistic-regression classifier is trained independently on each excitation
pattern using a replica-based train/test split.

The most discriminative excitation is:

```text
100–1000 Hz  →  accuracy = 1.000
```

while the broad 50–4000 Hz sweep reaches:

```text
accuracy = 0.945
```

The result is consistent with the FFT analysis: the strongest fault-sensitive
structural modes are concentrated in the lower-frequency region.

This suggests that a production monitoring system may not need the full
available spectrum.

## 4. Channel Sensitivity

All seven combinations of the three accelerometer axes are evaluated.

| Channels | Accuracy |
|---|---:|
| X | 0.925 |
| Y | 0.922 |
| Z | 0.901 |
| X + Y | 0.941 |
| X + Z | 0.951 |
| Y + Z | 0.949 |
| X + Y + Z | **0.960** |

All three axes contribute useful information.

The Z axis is weaker alone, but improves the combined model, indicating that
vertical vibration modes carry complementary information.

## 5. The Most Important Methodological Choice: Data Splitting

A naive random split would mix recordings from the same physical tests across
training and test sets.

That produces an optimistic estimate because the classifier can exploit
shared test-, board-, and excitation-specific structure.

The project therefore evaluates progressively harder split strategies.

### Logistic Regression

| Split strategy | Accuracy |
|---|---:|
| Naive random 80/20 | 0.966 |
| By replicate | 0.960 |
| By sensor board | 0.844 |
| By excitation pattern | 0.837 |
| Combined replicate × board × excitation | **0.750** |

The combined split is the most demanding test because the held-out data are
simultaneously new along all three dimensions.

On a three-class task with a 33.3% random baseline, the 0.750 result provides a
much more realistic estimate of out-of-distribution performance than the
naive 0.966 score.

## 6. Non-Linear Modelling

Random Forest is used to capture interactions between:

- axes;
- spectral bands;
- multiple resonance modes.

On the replica split:

```text
Random Forest accuracy = 0.9926
```

Per-class recall:

| Class | Recall |
|---|---:|
| 30NM | 1.00 |
| Loose | 1.00 |
| Mix-45° | 0.89 |

The intermediate `Mix-45°` state is the most difficult class, which is
consistent with its more subtle physical condition and smaller sample size.

## 7. Generalization: Random Forest vs Logistic Regression

| Split | Logistic Regression | Random Forest |
|---|---:|---:|
| Naive | 0.966 | 0.995 |
| Replica | 0.960 | 0.992 |
| Sensor board | 0.844 | **0.930** |
| Excitation | 0.837 | **0.883** |
| Combined | **0.750** | 0.667 |

The comparison reveals an important modelling trade-off.

Random Forest generalizes substantially better across unseen boards and
excitation patterns, but the simpler Logistic Regression is more robust on
the very small combined holdout.

This is treated as evidence against selecting a model purely from one headline
accuracy number.

## 8. Feature Importance and Physical Interpretation

Random Forest feature importance confirms that **spectral band energy** carries
most of the discriminative information.

The strongest features are concentrated in bands including:

- 400–600 Hz;
- 800–1200 Hz;
- 1200–1600 Hz.

This is especially valuable because three independent analyses converge:

1. visual FFT inspection;
2. excitation sensitivity;
3. Random Forest feature importance.

The model therefore reinforces, rather than replaces, the physical
interpretation.

## 9. Board Variability as a Deployment Risk

The accuracy drop from the replica split to the unseen-board split shows that
hardware variability is a major deployment challenge.

A realistic field system may therefore require:

- per-board healthy-state calibration;
- sensor-response normalization;
- broader training coverage across hardware units.

This is a more actionable conclusion than reporting only the best in-sample
classification accuracy.

## 10. Model Extension: LightGBM and Voting Ensemble

The project also tests LightGBM and a soft-voting Random Forest + LightGBM
ensemble on the unseen-board split.

| Model | Board-split accuracy |
|---|---:|
| Random Forest | **0.9304** |
| LightGBM | 0.8945 |
| RF + LightGBM ensemble | 0.9088 |

The ensemble does not outperform Random Forest, so model complexity is not
added without evidence of benefit.

## Methodological Strengths

The project emphasizes:

- signal-level preprocessing grounded in sensor physics;
- frequency-domain analysis before modelling;
- physically motivated feature engineering;
- explicit leakage diagnosis;
- multiple generalization tests;
- class-level evaluation;
- comparison of linear and non-linear models;
- interpretation of feature importance against structural mechanics;
- honest reporting of out-of-distribution degradation.

## Limitations

The current analysis is a laboratory classification study.

It does **not** yet establish:

- field failure probabilities;
- remaining useful life;
- transferability to arbitrary fixture geometries;
- robustness to environmental noise;
- performance under uncontrolled operational excitation.

The combined split also contains only 36 test observations, so its accuracy
has high statistical uncertainty.

## Production-Oriented Next Steps

A deployment path would include:

1. collect more observations from unseen boards and fixtures;
2. validate under operational environmental noise;
3. calibrate healthy baselines per sensor board;
4. focus acquisition on the most informative frequency range;
5. evaluate probability calibration and uncertainty;
6. move from discrete condition classification toward continuous structural
   health scoring.

## Repository Structure

```text
gdg-vibration-fault-detection/
├── README.md
├── notebooks/
│   ├── README.md
│   └── 01_vibration_fault_detection.ipynb
├── docs/
│   └── methodology.md
└── results/
    ├── README.md
    ├── fft_condition_comparison.png
    ├── sensitivity_analysis.png
    ├── split_generalization.png
    ├── model_comparison.png
    └── feature_importance.png
```

## Technology Stack

**Signal processing:** FFT, Hann windowing, spectral analysis, peak detection  
**Machine learning:** Logistic Regression, Random Forest, LightGBM, Voting Ensemble  
**Feature engineering:** band energy, spectral centroid, RMS  
**Validation:** grouped holdouts, OOD testing, confusion matrices  
**Libraries:** NumPy, Pandas, SciPy, Scikit-learn, LightGBM, Matplotlib, Seaborn

## Key Takeaway

The strongest result of this project is not the 99% accuracy achieved on an
easy split.

It is the demonstration that **validation design changes the scientific
conclusion**.

By progressively removing overlap across replicates, hardware units and
excitation patterns, the project separates memorization from genuine
structural fault learning — and shows exactly where the current system is
strong, where it generalizes, and where additional data are still required.
