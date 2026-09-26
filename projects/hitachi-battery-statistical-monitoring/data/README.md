# Data

The original Hitachi Rail train-level dataset is **not distributed** in this
repository.

The project was developed on industrial battery-monitoring data collected from
a high-speed train equipped with four parallel-connected Ni-Cd batteries.

## Source Structure

The original data include:

- `Timestamp`: measurement timestamp;
- `Vehicle`: train identifier;
- `GPS_LAT`, `GPS_LON`: location information;
- `VEHICLE_SPEED`: train speed;
- `POC_ID`: Point-of-Change identifier;
- `ID_GR`: charge/discharge group identifier;
- battery current measurements:
  - `IBatt_C2`
  - `IBatt_C4`
  - `IBatt_C5`
  - `IBatt_C7`
- battery voltage measurements:
  - `VBatt_C2`
  - `VBatt_C4`
  - `VBatt_C5`
  - `VBatt_C7`
- charge/discharge phase indicators:
  - `ID_Ph_C2`
  - `ID_Ph_C4`
  - `ID_Ph_C5`
  - `ID_Ph_C7`
- within-cycle row/time variables.

The project dataset contains approximately **200 charge/discharge groups**.

## Sign Convention

In the source data:

- negative current = battery discharging;
- positive current = battery charging.

For compositional monitoring of discharge contribution, the public analysis
uses the **absolute current magnitude** so that every component is positive and
can be interpreted as a share of the total discharge load.

## Derived Variables

For each battery, power is computed as:

```text
Power = Current × Voltage
```

The public feature-engineering script then summarizes each group by the median
of:

- current;
- absolute current magnitude;
- voltage;
- power.

This produces one robust observation per discharge cycle.

## Local Reproduction

Place the original RDS file locally and define:

```r
Sys.setenv(HITACHI_DATA = "data/Fleet_1_train_1.rds")
```

Then run:

```text
R/01_cycle_level_feature_engineering.R
```

The script creates:

```text
data/derived/cycle_level_features.rds
```

which is used by the control-chart scripts.

## Confidentiality

Raw industrial measurements, train identifiers and geographic coordinates are
excluded from the public portfolio.
