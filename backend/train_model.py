"""
Model training script for the Health Insurance Premium Predictor.

Trains a Linear Regression model on the medical insurance dataset,
evaluates performance metrics, and saves the trained artifact to disk.

Usage (from project root):
    python backend/train_model.py

Output:
    backend/models/insurance_model.pkl  — saved model artifact
"""

import sys
import os

# Ensure sibling modules (preprocess, utils) are importable regardless of CWD
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import numpy as np
import joblib
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_absolute_error, mean_squared_error

from preprocess import load_and_preprocess

# -------------------------------------------------------------------
# Paths
# -------------------------------------------------------------------
MODEL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "models")
MODEL_PATH = os.path.join(MODEL_DIR, "insurance_model.pkl")


def train_and_evaluate() -> None:
    """Train, evaluate, and persist the Linear Regression model."""

    print()
    print("=" * 58)
    print("   Health Insurance Premium Predictor — Model Training")
    print("=" * 58)

    # ------------------------------------------------------------------
    # Step 1 — Load & Preprocess Dataset
    # ------------------------------------------------------------------
    print("\n[1/4] Loading and preprocessing dataset...")
    X, y, feature_columns = load_and_preprocess()
    print(f"      Samples   : {X.shape[0]}")
    print(f"      Features  : {X.shape[1]}  →  {feature_columns}")

    # ------------------------------------------------------------------
    # Step 2 — Train / Test Split  (80% / 20%)
    # ------------------------------------------------------------------
    print("\n[2/4] Splitting dataset — 80% train / 20% test ...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42
    )
    print(f"      Training samples : {len(X_train)}")
    print(f"      Testing  samples : {len(X_test)}")

    # ------------------------------------------------------------------
    # Step 3 — Train Linear Regression
    # ------------------------------------------------------------------
    print("\n[3/4] Training Linear Regression model...")
    model = LinearRegression()
    model.fit(X_train, y_train)
    print("      Training complete.")

    # ------------------------------------------------------------------
    # Step 4 — Evaluate on Test Set
    # ------------------------------------------------------------------
    print("\n[4/4] Evaluating model on test set...")
    y_pred = model.predict(X_test)

    r2   = r2_score(y_test, y_pred)
    mae  = mean_absolute_error(y_test, y_pred)
    rmse = float(np.sqrt(mean_squared_error(y_test, y_pred)))

    print()
    print("  ┌──────────────────────────────────────────┐")
    print(f"  │  R² Score (accuracy)  :  {r2:.4f}           │")
    print(f"  │  MAE  (avg error)     :  ${mae:>10,.2f}     │")
    print(f"  │  RMSE (std of error)  :  ${rmse:>10,.2f}     │")
    print("  └──────────────────────────────────────────┘")

    # ------------------------------------------------------------------
    # Step 5 — Save Model Artifact
    # ------------------------------------------------------------------
    os.makedirs(MODEL_DIR, exist_ok=True)

    # Save model AND feature column order together so predict.py can
    # reconstruct inputs with the exact same schema as training.
    artifact = {
        "model": model,
        "feature_columns": feature_columns,
    }
    joblib.dump(artifact, MODEL_PATH)

    print(f"\n  ✓ Model artifact saved → {MODEL_PATH}")
    print("\n  The backend is ready. Start the server with:")
    print("      uvicorn main:app --reload --port 8000")
    print("  (Run from the backend/ directory)\n")


if __name__ == "__main__":
    train_and_evaluate()
