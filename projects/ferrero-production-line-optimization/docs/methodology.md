# Methodology Notes

## 1. Bottleneck Analysis

The production line is represented through four sequential stages:

1. Modeller
2. Primary Packaging
3. Secondary Packaging
4. Tray + Cover

For each stage, effective throughput is calculated as:

```text
speed × number of machines × unit weight × shift duration × OEE
```

Cycle time is computed as the inverse of effective output rate.

The stage with the lowest effective throughput is treated as the current
production bottleneck.

## 2. Capacity Rebalancing

The optimization focuses on Primary and Secondary Packaging because both are
below the 20,000 qls/year target under the final assumption of 250 shifts/year.

The integer program minimizes the total number of new machines while requiring
both stages to meet the target independently.

The resulting solution is:

- +1 Primary Packaging machine;
- +2 Secondary Packaging machines.

## 3. Buffer Logic

Buffers were evaluated between:

- Primary and Secondary Packaging;
- Secondary Packaging and Tray + Cover.

The expected benefits are reduced blocking/starving, smoother flow and greater
resilience. The analysis also recognizes the drawbacks of excessive WIP,
space requirements and process complexity.

## 4. Predictive Maintenance

The MATLAB prototype simulates a degradation index and uses two thresholds:

- warning level = 70;
- failure level = 80.

A linear trend is fitted to estimate when the degradation index may cross the
failure threshold.

The project roadmap extends this proof of concept toward an industrial setup
with condition-monitoring sensors, real-time data collection, predictive
analytics, maintenance scheduling and ROI monitoring.

## 5. Cost-Benefit Framework

The original project evaluates implementation costs and benefits across three
categories:

- estimable;
- variable;
- intangible.

The framework is qualitative: no fully monetized ROI is claimed in the public
portfolio.

## 6. Sustainable Packaging Extension

A secondary-packaging concept was proposed as an additional strategic
intervention, emphasizing stackability, recyclable materials, protection,
warehouse efficiency and pallet utilization.

This concept is kept separate from the quantitative production-line model.
