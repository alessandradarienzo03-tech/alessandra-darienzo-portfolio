# Source Code

This folder contains reusable Python components extracted from the original
research notebooks.

## Current Modules

### `segmentation.py`

Provides business-driven company segmentation based on:

- employee count;
- two-digit ATECO economic classification;
- five economic macro-sectors;
- normalized ESG score;
- three-year employment growth.

The segmentation rules are deterministic and interpretable. They should not
be confused with unsupervised clustering algorithms such as K-means.
