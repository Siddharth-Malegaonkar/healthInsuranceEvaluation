import pytest
from fastapi.testclient import TestClient

from main import app
from preprocess import preprocess_single


VALID_INPUT = {
    "age": 28, "gender": "male", "bmi": 24.8, "children": 1,
    "discount_eligibility": "yes", "region": "northwest",
}
FEATURES = ["age", "gender", "bmi", "children", "discount_eligibility", "region_northwest"]


@pytest.fixture
def client():
    return TestClient(app)


def test_api_rejects_age_below_minimum(client):
    response = client.post("/predict", json={**VALID_INPUT, "age": 17})
    assert response.status_code == 422


def test_api_rejects_bmi_above_maximum(client):
    response = client.post("/predict", json={**VALID_INPUT, "bmi": 60.1})
    assert response.status_code == 422


def test_api_rejects_negative_children(client):
    response = client.post("/predict", json={**VALID_INPUT, "children": -1})
    assert response.status_code == 422


def test_api_rejects_invalid_gender(client):
    response = client.post("/predict", json={**VALID_INPUT, "gender": "other"})
    assert response.status_code == 422


def test_api_rejects_missing_required_field(client):
    request = {key: value for key, value in VALID_INPUT.items() if key != "region"}
    response = client.post("/predict", json=request)
    assert response.status_code == 422


def test_preprocessing_rejects_unknown_region():
    with pytest.raises(ValueError, match="Invalid region"):
        preprocess_single({**VALID_INPUT, "region": "central"}, FEATURES)


def test_preprocessing_rejects_non_finite_bmi():
    with pytest.raises(ValueError, match="BMI must be"):
        preprocess_single({**VALID_INPUT, "bmi": float("nan")}, FEATURES)
