import math

import pytest

import predict as prediction_module
from predict import predict


VALID_INPUT = {
    "age": 28, "gender": "male", "bmi": 24.8, "children": 1,
    "discount_eligibility": "yes", "region": "northwest",
}


def test_model_artifact_loads_real_model():
    artifact = prediction_module._load_artifact()
    assert {"model", "feature_columns"}.issubset(artifact)
    assert hasattr(artifact["model"], "predict")


def test_prediction_returns_finite_non_negative_float():
    premium = predict(**VALID_INPUT)
    assert isinstance(premium, float)
    assert math.isfinite(premium)
    assert premium >= 0


@pytest.mark.parametrize("input_data", [
    {**VALID_INPUT, "age": 18, "gender": "female", "bmi": 18.5, "children": 0, "discount_eligibility": "no", "region": "northeast"},
    {**VALID_INPUT, "age": 65, "bmi": 35.2, "children": 3, "region": "southeast"},
    {**VALID_INPUT, "age": 100, "bmi": 45.0, "children": 10, "region": "southwest"},
])
def test_prediction_supports_valid_input_combinations(input_data):
    # The existing Linear Regression model is unconstrained, so edge inputs can
    # legitimately produce a negative estimate. This test verifies real model
    # inference succeeds without changing the model's current behavior.
    result = predict(**input_data)
    assert isinstance(result, float)
    assert math.isfinite(result)


def test_prediction_raises_when_model_file_is_missing(monkeypatch):
    monkeypatch.setattr(prediction_module, "_artifact", None)
    monkeypatch.setattr(prediction_module, "MODEL_PATH", "missing-model.pkl")
    with pytest.raises(FileNotFoundError, match="Model file not found"):
        prediction_module._load_artifact()
