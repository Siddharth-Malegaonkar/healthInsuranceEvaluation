"""
Prediction module for the Health Insurance Premium Predictor.

Loads the trained model artifact from disk once at module import and
exposes a single predict() function used by the FastAPI endpoints.
"""

import sys
import os

# Ensure sibling modules are importable regardless of working directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import joblib

from preprocess import preprocess_single
from utils import round_premium

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
MODEL_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "models", "insurance_model.pkl"
)

# Module-level cache — loaded once, reused for every request
_artifact: dict | None = None


def _load_artifact() -> dict:
    """Lazily load the model artifact from disk (singleton pattern)."""
    global _artifact
    if _artifact is None:
        if not os.path.exists(MODEL_PATH):
            raise FileNotFoundError(
                f"Model file not found at '{MODEL_PATH}'. "
                "Please run 'python backend/train_model.py' first."
            )
        _artifact = joblib.load(MODEL_PATH)
    return _artifact


def predict(
    age: int,
    gender: str,
    bmi: float,
    children: int,
    discount_eligibility: str,
    region: str,
) -> float:
    """
    Predict the annual health insurance premium for a given individual.

    Args:
        age: Age of the individual (18–100).
        gender: 'male' or 'female'.
        bmi: Body Mass Index (10.0–60.0).
        children: Number of dependents (0–10).
        discount_eligibility: 'yes' or 'no'.
        region: One of 'northeast', 'northwest', 'southeast', 'southwest'.

    Returns:
        Predicted annual medical expenses rounded to 2 decimal places.

    Raises:
        FileNotFoundError: If the model has not been trained yet.
        ValueError: If input data cannot be preprocessed correctly.
    """
    artifact = _load_artifact()
    model = artifact["model"]
    feature_columns = artifact["feature_columns"]

    input_dict = {
        "age": age,
        "gender": gender,
        "bmi": bmi,
        "children": children,
        "discount_eligibility": discount_eligibility,
        "region": region,
    }

    # Transform input using the same encoding as training
    input_df = preprocess_single(input_dict, feature_columns)

    raw_prediction = model.predict(input_df)[0]

    return round_premium(raw_prediction)
