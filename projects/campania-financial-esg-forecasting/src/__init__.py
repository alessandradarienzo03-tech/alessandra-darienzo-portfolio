"""Reusable components for the Campania financial and ESG forecasting project."""

from .segmentation import (
    add_company_segments,
    assign_economic_sector,
    assign_employment_trend,
    assign_esg_rating,
    assign_firm_size,
    assign_macro_sector,
)

__all__ = [
    "add_company_segments",
    "assign_economic_sector",
    "assign_employment_trend",
    "assign_esg_rating",
    "assign_firm_size",
    "assign_macro_sector",
]
