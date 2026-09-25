# MATLAB Models

This folder contains the public MATLAB implementation of the core analytical
components of the Ferrero Challengineers project.

| File | Purpose |
|---|---|
| [`01_bottleneck_capacity_analysis.m`](01_bottleneck_capacity_analysis.m) | Computes effective throughput, annual capacity and cycle time for each production stage and identifies the bottleneck |
| [`02_line_balancing_optimization.m`](02_line_balancing_optimization.m) | Uses integer linear programming to determine the minimum additional packaging capacity required to meet the annual target |
| [`03_predictive_maintenance_prototype.m`](03_predictive_maintenance_prototype.m) | Demonstrates a reproducible degradation simulation, maintenance-warning logic and linear time-to-failure estimation |

## Requirements

- MATLAB
- Optimization Toolbox (`intlinprog`) for the line-balancing model

The scripts reproduce the final project assumption of **250 shifts/year**.
