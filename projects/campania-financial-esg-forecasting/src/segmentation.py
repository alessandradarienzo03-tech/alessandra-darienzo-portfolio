"""Business-driven segmentation utilities for private companies.

The functions in this module assign companies to interpretable groups based
on firm size, economic activity and ESG performance.

These groups are defined through business rules rather than unsupervised
clustering algorithms.
"""

from __future__ import annotations

from typing import Final

import numpy as np
import pandas as pd


FIRM_SIZE_LABELS: Final[list[str]] = [
    "micro",
    "small",
    "medium_large",
]

ATECO_SECTIONS: Final[dict[str, list[str]]] = {
    "Manufacturing": [str(code).zfill(2) for code in range(10, 34)],
    "Energy": ["35"],
    "Water and Waste": ["36", "37", "38", "39"],
    "Construction": ["41", "42", "43"],
    "Trade": ["45", "46", "47"],
    "Transport": ["49", "50", "51", "52", "53"],
    "Accommodation and Food": ["55", "56"],
    "Information and Communication": ["58", "59", "60", "61", "62", "63"],
    "Finance": ["64", "65", "66"],
    "Real Estate": ["68"],
    "Professional and Technical": ["69", "70", "71", "72", "73", "74", "75"],
    "Business Support": ["77", "78", "79", "80", "81", "82"],
    "Education": ["85"],
    "Healthcare": ["86", "87", "88"],
    "Arts and Sport": ["90", "91", "92", "93"],
    "Other Services": ["94", "95", "96"],
}

MACRO_SECTOR_MAP: Final[dict[str, str]] = {
    "Manufacturing": "Industry and Construction",
    "Construction": "Industry and Construction",
    "Energy": "Networks, Logistics and Infrastructure",
    "Water and Waste": "Networks, Logistics and Infrastructure",
    "Transport": "Networks, Logistics and Infrastructure",
    "Trade": "Trade and Consumer Services",
    "Accommodation and Food": "Trade and Consumer Services",
    "Information and Communication": "Knowledge Economy and Advanced Services",
    "Professional and Technical": "Knowledge Economy and Advanced Services",
    "Business Support": "Knowledge Economy and Advanced Services",
    "Finance": "Finance, Real Estate and Collective Services",
    "Real Estate": "Finance, Real Estate and Collective Services",
    "Education": "Finance, Real Estate and Collective Services",
    "Healthcare": "Finance, Real Estate and Collective Services",
    "Arts and Sport": "Finance, Real Estate and Collective Services",
    "Other Services": "Finance, Real Estate and Collective Services",
}


def assign_firm_size(employees: pd.Series) -> pd.Series:
    """Assign companies to size categories using employee counts.

    Categories:
        - micro: 0–9 employees
        - small: 10–49 employees
        - medium_large: 50 or more employees
    """
    numeric_employees = pd.to_numeric(employees, errors="coerce")

    return pd.cut(
        numeric_employees,
        bins=[-np.inf, 9, 49, np.inf],
        labels=FIRM_SIZE_LABELS,
        include_lowest=True,
    )


def build_ateco_sector_mapping() -> dict[str, str]:
    """Create a mapping from two-digit ATECO divisions to sectors."""
    return {
        division: sector
        for sector, divisions in ATECO_SECTIONS.items()
        for division in divisions
    }


def assign_economic_sector(ateco_codes: pd.Series) -> pd.Series:
    """Map ATECO codes to interpretable economic sectors."""
    ateco_divisions = (
        ateco_codes.astype("string")
        .str.replace(r"\.0$", "", regex=True)
        .str.zfill(2)
        .str[:2]
    )

    sector_mapping = build_ateco_sector_mapping()
    return ateco_divisions.map(sector_mapping)


def assign_macro_sector(sectors: pd.Series) -> pd.Series:
    """Aggregate detailed sectors into five economic macro-sectors."""
    return sectors.map(MACRO_SECTOR_MAP)


def assign_esg_rating(esg_scores: pd.Series) -> pd.Series:
    """Convert normalized ESG scores into four ordered rating groups."""
    numeric_scores = pd.to_numeric(esg_scores, errors="coerce")

    return pd.cut(
        numeric_scores,
        bins=[-np.inf, 0.25, 0.50, 0.75, np.inf],
        labels=["D", "C", "B", "A"],
        include_lowest=True,
    )


def assign_employment_trend(
    current_employees: pd.Series,
    past_employees: pd.Series,
    years: int = 3,
    threshold: float = 0.10,
) -> pd.Series:
    """Classify employment trends using annualized growth.

    Companies are classified as:
        - growing: CAGR >= threshold
        - declining: CAGR <= -threshold
        - stable: otherwise
    """
    current = pd.to_numeric(current_employees, errors="coerce")
    past = pd.to_numeric(past_employees, errors="coerce")

    valid = (current >= 0) & (past > 0)
    cagr = pd.Series(np.nan, index=current.index, dtype=float)

    cagr.loc[valid] = (
        current.loc[valid] / past.loc[valid]
    ) ** (1 / years) - 1

    return pd.Series(
        np.select(
            [cagr >= threshold, cagr <= -threshold],
            ["growing", "declining"],
            default="stable",
        ),
        index=current.index,
        dtype="string",
    ).mask(cagr.isna())


def add_company_segments(
    dataframe: pd.DataFrame,
    employee_column: str,
    ateco_column: str,
    esg_column: str | None = None,
) -> pd.DataFrame:
    """Return a copy of the dataset enriched with company segments."""
    required_columns = {employee_column, ateco_column}
    missing_columns = required_columns.difference(dataframe.columns)

    if missing_columns:
        raise KeyError(
            f"Missing required columns: {sorted(missing_columns)}"
        )

    result = dataframe.copy()

    result["firm_size"] = assign_firm_size(result[employee_column])
    result["economic_sector"] = assign_economic_sector(result[ateco_column])
    result["macro_sector"] = assign_macro_sector(result["economic_sector"])

    if esg_column is not None:
        if esg_column not in result.columns:
            raise KeyError(f"Missing ESG column: {esg_column}")

        result["esg_rating"] = assign_esg_rating(result[esg_column])

    return result
