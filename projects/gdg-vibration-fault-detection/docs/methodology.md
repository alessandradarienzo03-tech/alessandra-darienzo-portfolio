# Methodology

## 1. Problem Formulation

The project studies whether changes in fixture mounting condition can be
detected from three-axis vibration measurements.

Three classes are considered:

- **30NM** — healthy / correctly tightened fixture;
- **Loose** — loose-bolt condition;
- **Mix-45°** — intermediate mixed condition.

The objective is not only to classify these states, but to determine whether
the learned signal is physically meaningful and whether it generalizes beyond
the exact recordings seen during training.

## 2. Experimental Structure

The source experiment contains:

- multiple excitation patterns;
- five replicates of repeated test conditions;
- 15 accelerometer boards;
- three axes (`X`, `Y`, `Z`);
- 8,192 samples per recording;
- sampling frequency of 27 kHz.

The final feature dataset contains **6,004 recordings**.

The raw dataset is not redistributed in the public portfolio.

## 3. Signal Preprocessing

The exploratory analysis begins with the raw time series and FFT spectra.

The Z axis contains a strong DC component caused by gravity. The corrected
spectral pipeline therefore applies:

```text
raw acceleration
→ mean subtraction
→ Hann window
→ FFT
→ magnitude normalization
```

Mean subtraction removes the DC bias.

Hann windowing reduces spectral leakage.

Normalization makes spectra more comparable across captures with different
excitation amplitudes.

## 4. Physics-Informed Spectral Analysis

The corrected FFT comparison reveals sharper resonance peaks under the loose
condition.

Representative peaks observed in the project include:

- X: approximately 168, 396, 573 and 728 Hz;
- Y: approximately 396, 570 and 728 Hz;
- Z: approximately 129, 233, 386 and 570 Hz.

This motivates a feature representation based on spectral energy rather than
an unstructured raw-signal classifier.

## 5. Feature Engineering

Each recording is transformed into 36 features.

For each of the three axes:

- energy in 10 frequency bands between 0 and 4 kHz;
- spectral centroid;
- RMS amplitude.

Therefore:

```text
3 axes × 12 features = 36 features
```

The features are chosen to capture resonance location, spectral energy
redistribution and overall vibration amplitude.

## 6. Excitation Sensitivity

Logistic Regression is trained independently on each excitation pattern using
a replicate-based split.

Reported results:

| Excitation | Accuracy |
|---|---:|
| 100–1000 Hz | **1.000** |
| 50–1000 Hz | 0.988 |
| 50–200 Hz | 0.976 |
| 100–200 Hz | 0.975 |
| 50–4000 Hz | 0.945 |

The result confirms that the most useful structural information is
concentrated in the lower-frequency resonance range rather than uniformly
across the full spectrum.

## 7. Channel Sensitivity

All seven combinations of the accelerometer axes are evaluated.

| Channels | Accuracy |
|---|---:|
| X | 0.925 |
| Y | 0.922 |
| Z | 0.901 |
| X + Y | 0.941 |
| X + Z | 0.951 |
| Y + Z | 0.949 |
| X + Y + Z | **0.960** |

Although Z is the weakest standalone axis, it improves the three-axis model.
The three channels therefore contain complementary structural information.

## 8. Leakage-Aware Validation

The most important methodological decision is the validation design.

A naive random file split can place recordings from the same physical test in
both training and test sets because the same experiment is captured by
multiple sensor boards and replicates.

Five split strategies are therefore compared:

| Split | Logistic Regression | Random Forest |
|---|---:|---:|
| Naive random | 0.966 | 0.995 |
| Replicate holdout | 0.960 | 0.992 |
| Sensor-board holdout | 0.844 | 0.930 |
| Excitation holdout | 0.837 | 0.883 |
| Combined holdout | **0.750** | 0.667 |

The accuracy drop is treated as information rather than hidden.

It identifies sensor hardware and excitation conditions as important sources
of deployment uncertainty.

The combined holdout contains only **36 test observations**, so the comparison
between models on that split has high sampling uncertainty.

## 9. Model Progression

### Logistic Regression

Logistic Regression provides an interpretable linear baseline and shows that
the engineered spectral features contain substantial linearly separable
information.

### Random Forest

Random Forest captures nonlinear interactions between axes and frequency
bands.

On the replica split, the original run reports:

```text
accuracy = 0.9926
```

with recall:

- 30NM: 1.00;
- Loose: 1.00;
- Mix-45°: 0.89.

The intermediate condition is the most difficult class.

### LightGBM and Voting Ensemble

The board holdout is also evaluated with LightGBM and a soft-voting ensemble.

| Model | Board-split accuracy |
|---|---:|
| Random Forest | **0.9304** |
| LightGBM | 0.8945 |
| RF + LightGBM ensemble | 0.9088 |

The ensemble does not improve on Random Forest.

## 10. Feature Importance

Random Forest feature importance provides an independent check of the
physics-driven hypothesis.

The most influential variables are spectral band-energy features, especially
in ranges including:

- 400–600 Hz;
- 800–1200 Hz;
- 1200–1600 Hz.

The key scientific result is the convergence of three independent analyses:

```text
FFT inspection
+ excitation sensitivity
+ model feature importance
→ physically meaningful resonance regions
```

## 11. Deployment Interpretation

The unseen-board split is particularly important because a field deployment
would use hardware units not present during training.

The reduction in accuracy on new boards suggests a production system could
benefit from:

- a short healthy-state calibration for each sensor;
- board-response normalization;
- broader training coverage across hardware units.

Likewise, excitation sensitivity suggests prioritizing the most diagnostic
frequency range instead of processing the full available spectrum.

## 12. Limitations

The current study is based on controlled laboratory data.

It does not establish:

- real-world failure probability;
- remaining useful life;
- robustness to uncontrolled environmental vibration;
- transferability across arbitrary fixture geometries;
- field performance under naturally varying excitation.

The project should therefore be interpreted as a rigorous structural
condition-classification study and a foundation for future condition
monitoring.
