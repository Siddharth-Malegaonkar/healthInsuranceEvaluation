"""
Utility helpers for the Health Insurance Premium Predictor backend.
"""


def format_currency(amount: float, symbol: str = "$") -> str:
    """Format a float as a readable currency string.

    Args:
        amount: The numeric amount to format.
        symbol: Currency symbol prefix (default '$').

    Returns:
        Formatted string, e.g. '$12,345.67'.
    """
    return f"{symbol}{amount:,.2f}"


def round_premium(amount: float, decimals: int = 2) -> float:
    """Round a predicted premium to a specified number of decimal places."""
    return round(float(amount), decimals)
