"""
FastAPI backend for the Health Insurance Premium Predictor.

Provides two REST API endpoints:
    GET  /health   — returns API health status
    POST /predict  — accepts patient details, returns predicted premium

Run the server (from the backend/ directory):
    uvicorn main:app --reload --port 8000

Interactive API docs (auto-generated):
    http://localhost:8000/docs
"""

import sys
import os

# Ensure sibling modules (predict, preprocess, utils) are importable
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware

from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Literal

from predict import predict

# -------------------------------------------------------------------
# App Configuration
# -------------------------------------------------------------------
app = FastAPI(
    title="Health Insurance Premium Predictor API",
    description=(
        "A REST API that uses a trained Linear Regression model to predict "
        "annual health insurance premiums based on patient demographics."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Allow cross-origin requests from the Flutter app (local dev + emulator)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)


# -------------------------------------------------------------------
# Pydantic Schemas
# -------------------------------------------------------------------

class PredictionRequest(BaseModel):
    """Request body for the /predict endpoint."""

    age: int = Field(
        ..., ge=18, le=100,
        description="Age of the individual (18–100)"
    )
    gender: Literal["male", "female"] = Field(
        ..., description="Gender: 'male' or 'female'"
    )
    bmi: float = Field(
        ..., ge=10.0, le=60.0,
        description="Body Mass Index (10.0–60.0)"
    )
    children: int = Field(
        ..., ge=0, le=10,
        description="Number of dependents (0–10)"
    )
    discount_eligibility: Literal["yes", "no"] = Field(
        ..., description="Whether the individual qualifies for a discount: 'yes' or 'no'"
    )
    region: Literal["northeast", "northwest", "southeast", "southwest"] = Field(
        ..., description="Residential region"
    )

    model_config = {
        "json_schema_extra": {
            "example": {
                "age": 28,
                "gender": "male",
                "bmi": 24.8,
                "children": 1,
                "discount_eligibility": "yes",
                "region": "northwest",
            }
        }
    }


class PredictionResponse(BaseModel):
    """Successful prediction response."""
    predicted_premium: float = Field(
        ..., description="Predicted annual medical expenses (USD)"
    )


class HealthResponse(BaseModel):
    """Health check response."""
    status: str


# -------------------------------------------------------------------
# Endpoints
# -------------------------------------------------------------------

@app.get(
    "/health",
    response_model=HealthResponse,
    tags=["Health"],
    summary="API health check",
)
async def health_check():
    """Returns a simple status object confirming the API is running."""
    return {"status": "running"}


@app.post(
    "/predict",
    response_model=PredictionResponse,
    tags=["Prediction"],
    summary="Predict health insurance premium",
)
async def predict_premium(request: PredictionRequest):
    """
    Predict the annual health insurance premium for an individual.

    Accepts demographic and health details, runs them through the trained
    Linear Regression model, and returns the predicted annual cost.
    """
    try:
        predicted_premium = predict(
            age=request.age,
            gender=request.gender,
            bmi=request.bmi,
            children=request.children,
            discount_eligibility=request.discount_eligibility,
            region=request.region,
        )
        return PredictionResponse(predicted_premium=predicted_premium)

    except FileNotFoundError as exc:
        raise HTTPException(
            status_code=503,
            detail=(
                "The ML model is not available. "
                "Please run 'python backend/train_model.py' to train the model first."
            ),
        ) from exc

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Prediction failed: {str(exc)}",
        ) from exc


# -------------------------------------------------------------------
# Global Exception Handler
# -------------------------------------------------------------------

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    """Catch-all handler for any unhandled exceptions."""
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred. Please try again later."},
    )
