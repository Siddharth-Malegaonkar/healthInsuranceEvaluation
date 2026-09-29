"""
Data preprocessing module for the Health Insurance Premium Predictor.

Handles loading, cleaning, and feature encoding of the medical insurance dataset.
This module is used both during training (load_and_preprocess) and
inference time (preprocess_single).
"""

import os
import math
import pandas as pd

# Absolute path to the dataset, derived relative to this file
DATASET_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dataset", "medical_insurance.csv")

# Valid categorical values used for input sanity checks
VALID_GENDERS = {"male", "female"}
VALID_REGIONS = {"northeast", "northwest", "southeast", "southwest"}
VALID_DISCOUNT = {"yes", "no"}


def _validate_prediction_input(input_dict: dict) -> None:
    """Validate raw inference input before feature encoding.

    FastAPI validates HTTP requests, but this keeps direct callers of
    ``predict()`` and ``preprocess_single()`` equally safe and predictable.
    """
    required_fields = {
        "age", "gender", "bmi", "children", "discount_eligibility", "region"
    }
    missing_fields = required_fields - input_dict.keys()
    if missing_fields:
        raise ValueError(f"Missing required fields: {', '.join(sorted(missing_fields))}")

    for name, valid_values in (
        ("gender", VALID_GENDERS),
        ("discount_eligibility", VALID_DISCOUNT),
        ("region", VALID_REGIONS),
    ):
        value = input_dict[name]
        if not isinstance(value, str) or value.strip().lower() not in valid_values:
            raise ValueError(f"Invalid {name}: {value!r}")

    try:
        age = int(input_dict["age"])
        bmi = float(input_dict["bmi"])
        children = int(input_dict["children"])
    except (TypeError, ValueError) as exc:
        raise ValueError("Age, BMI, and children must be numeric.") from exc

    if not 18 <= age <= 100:
        raise ValueError("Age must be between 18 and 100.")
    if not math.isfinite(bmi) or not 10.0 <= bmi <= 60.0:
        raise ValueError("BMI must be a finite value between 10.0 and 60.0.")
    if not 0 <= children <= 10:
        raise ValueError("Children must be between 0 and 10.")


def load_and_preprocess() -> tuple:
    """
    Load and preprocess the full medical insurance dataset for model training.

    Steps:
        1. Load CSV from disk.
        2. Drop rows with missing values.
        3. Drop the derived 'premium' column (= expenses / 100, not used).
        4. Binary-encode 'gender' and 'discount_eligibility'.
        5. One-hot encode 'region' (drop_first=True keeps northeast as reference).

    Returns:
        X (pd.DataFrame): Feature matrix with encoded columns.
        y (pd.Series): Target variable — annual medical expenses (float).
        feature_columns (list[str]): Ordered list of feature column names.
    """
    df = pd.read_csv(DATASET_PATH)

    # Drop rows with any missing values
    initial_count = len(df)
    df.dropna(inplace=True)
    dropped = initial_count - len(df)
    if dropped > 0:
        print(f"      Dropped {dropped} rows with missing values.")

    # Drop derived column — not a meaningful predictor
    df.drop(columns=["premium"], inplace=True)

    # --- Categorical Encoding ---

    # Binary: gender  (male → 1, female → 0)
    df["gender"] = df["gender"].str.strip().str.lower().map({"male": 1, "female": 0})

    # Binary: discount_eligibility  (yes → 1, no → 0)
    df["discount_eligibility"] = (
        df["discount_eligibility"].str.strip().str.lower().map({"yes": 1, "no": 0})
    )

    # One-hot: region — drop_first=True uses 'northeast' as the reference category,
    # producing columns: region_northwest, region_southeast, region_southwest
    df = pd.get_dummies(df, columns=["region"], drop_first=True)

    # Split into features and target
    X = df.drop(columns=["expenses"])
    y = df["expenses"]

    feature_columns = list(X.columns)

    return X, y, feature_columns


def preprocess_single(input_dict: dict, feature_columns: list) -> pd.DataFrame:
    """
    Preprocess a single prediction input to match the training feature schema.

    Applies the exact same transformations used during training so the model
    receives correctly structured input.

    Args:
        input_dict: Dictionary with keys:
            age (int), gender (str), bmi (float), children (int),
            discount_eligibility (str), region (str).
        feature_columns: Ordered list of column names from training
            (stored in the model artifact).

    Returns:
        pd.DataFrame: Single-row DataFrame with columns ordered to match training.
    """
    _validate_prediction_input(input_dict)

    gender = 1 if input_dict["gender"].strip().lower() == "male" else 0
    discount = 1 if input_dict["discount_eligibility"].strip().lower() == "yes" else 0
    region = input_dict["region"].strip().lower()

    # Build base numeric features
    data: dict = {
        "age": float(input_dict["age"]),
        "bmi": float(input_dict["bmi"]),
        "children": int(input_dict["children"]),
        "gender": gender,
        "discount_eligibility": discount,
    }

    # Reconstruct region one-hot columns to match training schema
    for col in feature_columns:
        if col.startswith("region_"):
            region_name = col.replace("region_", "")
            data[col] = 1 if region == region_name else 0

    df = pd.DataFrame([data])

    # Enforce correct column order (critical for correct model predictions)
    df = df[feature_columns]

    return df
