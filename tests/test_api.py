from fastapi.testclient import TestClient

import main


VALID_INPUT = {
    "age": 28, "gender": "male", "bmi": 24.8, "children": 1,
    "discount_eligibility": "yes", "region": "northwest",
}


def test_health_endpoint_reports_running():
    response = TestClient(main.app).get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "running"}


def test_predict_endpoint_returns_real_prediction():
    response = TestClient(main.app).post("/predict", json=VALID_INPUT)
    body = response.json()
    assert response.status_code == 200
    assert isinstance(body["predicted_premium"], float)
    assert body["predicted_premium"] >= 0


def test_predict_endpoint_accepts_female_reference_region():
    response = TestClient(main.app).post(
        "/predict", json={**VALID_INPUT, "gender": "female", "region": "northeast"}
    )
    assert response.status_code == 200


def test_predict_endpoint_returns_service_unavailable_for_missing_model(monkeypatch):
    def raise_missing_model(**_kwargs):
        raise FileNotFoundError("model missing")

    monkeypatch.setattr(main, "predict", raise_missing_model)
    response = TestClient(main.app).post("/predict", json=VALID_INPUT)
    assert response.status_code == 503
    assert "ML model is not available" in response.json()["detail"]


def test_predict_endpoint_returns_server_error_for_prediction_failure(monkeypatch):
    def raise_prediction_error(**_kwargs):
        raise RuntimeError("unexpected model failure")

    monkeypatch.setattr(main, "predict", raise_prediction_error)
    response = TestClient(main.app, raise_server_exceptions=False).post("/predict", json=VALID_INPUT)
    assert response.status_code == 500
    assert "Prediction failed" in response.json()["detail"]
