# Ferrero Challengineers — Production Line Optimization & Predictive Maintenance

**Kinder Bueno Eggs Bottleneck Analysis — Team BuenoUnina**

An industrial analytics project developed for the Ferrero Challengineers
challenge, focused on identifying production bottlenecks and designing
data-driven interventions for a Kinder Bueno Eggs manufacturing line.

## Project Objective

The project asks a practical operations question:

> How can the production line meet an annual target of 20,000 qls while
> improving flow efficiency, equipment reliability and long-term scalability?

The analysis combines:

- production-capacity modelling;
- throughput and cycle-time analysis;
- Overall Equipment Effectiveness (OEE);
- bottleneck identification;
- integer optimization for line rebalancing;
- buffer-design logic;
- predictive-maintenance prototyping;
- qualitative cost-benefit evaluation;
- a sustainability-oriented secondary-packaging concept.

## Production Assumptions

The public model uses the final project assumption of:

- **8 hours per shift**
- **250 shifts per year**
- **20,000 qls/year production target**

The four production stages are:

1. Modeller
2. Primary Packaging
3. Secondary Packaging
4. Tray + Cover

## Bottleneck Diagnosis

The MATLAB model converts machine speed, installed capacity, product weight
and OEE into effective throughput and cycle time.

| Stage | Machines | OEE | Effective throughput (qls/shift) | Annual capacity (qls) |
|---|---:|---:|---:|---:|
| Modeller | 1 | 0.80 | 80.64 | 20,160 |
| Primary Packaging | 8 | 0.65 | 78.62 | 19,656 |
| Secondary Packaging | 9 | 0.70 | **71.44** | **17,860.5** |
| Tray + Cover | 3 | 0.80 | 91.45 | 22,861.4 |

The analysis identifies **Secondary Packaging as the current bottleneck**:
it has the lowest effective throughput and the highest cycle time.

Primary Packaging is also flagged as a potential future constraint because its
annual capacity remains below the 20,000 qls target.

## Line Rebalancing Optimization

An integer linear optimization model is used to determine the minimum number
of additional machines required in Primary and Secondary Packaging.

### Decision variables

- `x_B`: additional Primary Packaging machines
- `x_C`: additional Secondary Packaging machines

### Objective

```text
minimize x_B + x_C
```

subject to each stage reaching the annual production target.

### Optimal solution

The model returns:

- **+1 Primary Packaging machine**
- **+2 Secondary Packaging machines**

This reduces the cycle-time imbalance across the line:

| Stage | Before | After |
|---|---:|---:|
| Modeller | 5.95 | 5.95 |
| Primary Packaging | 6.10 | ~5.42 |
| Secondary Packaging | ~6.70 | ~5.50 |
| Tray + Cover | 5.20 | 5.20 |

All values are expressed in minutes per quintal.

## Buffer Strategy

The project also evaluates strategically placed buffers as a complementary
flow-stabilization measure.

Two candidate positions are considered:

- between Primary and Secondary Packaging;
- between Secondary Packaging and Tray + Cover.

The purpose is to reduce starving and blocking effects, decouple adjacent
stages and improve resilience to local disturbances.

The project explicitly treats buffer sizing as a trade-off: excessive buffers
can increase WIP, space requirements and operational complexity.

## Predictive Maintenance Prototype

A MATLAB proof of concept simulates progressive equipment degradation and
introduces:

- a warning threshold;
- a failure threshold;
- maintenance-trigger logic;
- a simple linear-regression estimate of time to failure.

The prototype is intentionally lightweight: it demonstrates the logic of
condition-based maintenance rather than claiming a production-ready failure
prediction model.

The broader implementation roadmap considered:

1. IoT sensor deployment;
2. real-time data acquisition;
3. predictive analytics;
4. maintenance scheduling;
5. continuous model refinement;
6. ROI monitoring.

## OEE Improvement Logic

Predictive maintenance is connected to the three OEE components:

- **Availability:** fewer unplanned stops and shorter repair times;
- **Performance:** fewer micro-stops and speed losses;
- **Quality:** earlier detection of process drift and lower scrap/rework.

## Secondary Packaging Concept

As a strategic extension, the project explores a more stackable and
sustainable secondary-packaging concept.

The proposed design emphasizes:

- better pallet and warehouse utilization;
- product protection;
- recyclable / FSC-certified materials;
- reduced transport footprint;
- compatibility with the existing packaging process;
- distinctive shelf presence.

This section is presented as a design concept rather than a quantitatively
validated engineering redesign.

## Repository Structure

```text
ferrero-production-line-optimization/
├── README.md
├── matlab/
│   ├── README.md
│   ├── 01_bottleneck_capacity_analysis.m
│   ├── 02_line_balancing_optimization.m
│   └── 03_predictive_maintenance_prototype.m
├── docs/
│   └── methodology.md
└── results/
```

## Technology Stack

**Industrial analytics:** throughput, cycle time, OEE, bottleneck analysis  
**Optimization:** integer linear programming  
**Predictive maintenance:** degradation simulation, threshold monitoring, linear regression  
**Programming:** MATLAB  
**Operations concepts:** line balancing, buffers, capacity planning, cost-benefit analysis

## Key Takeaways

This project connects industrial engineering with data-driven decision making.

The main contribution is not a single algorithm, but an integrated operational
workflow:

**measure → identify the constraint → optimize capacity → stabilize flow →
anticipate failures → evaluate implementation trade-offs.**
