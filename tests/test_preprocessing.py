import pandas as pd
import pytest

from preprocess import load_and_preprocess, preprocess_single


VALID_INPUT = {
    "age": 28, "gender": "male", "bmi": 24.8, "children": 1,
    "discount_eligibility": "yes", "region": "northwest",
}


@pytest.fixture(scope="module")
def training_data():
    return load_and_preprocess()


def test_training_data_has_features_and_target(training_data):
    X, y, _ = training_data
    assert not X.empty
    assert len(X) == len(y)
    assert y.name == "expenses"


def test_training_features_have_no_missing_values(training_data):
    X, _, _ = training_data
    assert not X.isna().any().any()


def test_feature_columns_match_training_matrix(training_data):
    X, _, feature_columns = training_data
    assert feature_columns == list(X.columns)
    assert "expenses" not in feature_columns
    assert "premium" not in feature_columns


def test_single_input_uses_training_feature_order(training_data):
    _, _, feature_columns = training_data
    result = preprocess_single(VALID_INPUT, feature_columns)
    assert list(result.columns) == feature_columns
    assert result.shape == (1, len(feature_columns))


def test_single_input_encodes_categories(training_data):
    _, _, feature_columns = training_data
    result = preprocess_single(VALID_INPUT, feature_columns)
    assert result.loc[0, "gender"] == 1
    assert result.loc[0, "discount_eligibility"] == 1
    assert result.loc[0, "region_northwest"] == 1


def test_reference_region_has_no_active_region_flag(training_data):
    _, _, feature_columns = training_data
    result = preprocess_single({**VALID_INPUT, "gender": " FEMALE ", "region": "northeast"}, feature_columns)
    region_columns = [column for column in feature_columns if column.startswith("region_")]
    assert result.loc[0, "gender"] == 0
    assert result.loc[0, region_columns].sum() == 0


def test_single_input_requires_all_fields(training_data):
    _, _, feature_columns = training_data
    with pytest.raises(ValueError, match="Missing required fields"):
        preprocess_single({"age": 28}, feature_columns)
