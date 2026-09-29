# Adaptive Test Selection demo

This repository keeps tests grouped by the backend area they exercise. That makes
it useful as a small, realistic input to an external Adaptive Test Selection
system: source-file changes and the test files are naturally related.

| Change area | Source files | Most relevant tests |
| --- | --- | --- |
| Validation | `backend/preprocess.py`, `backend/main.py` | `tests/test_validation.py` |
| Preprocessing | `backend/preprocess.py` | `tests/test_preprocessing.py` |
| Prediction/model loading | `backend/predict.py`, `backend/train_model.py` | `tests/test_prediction.py` |
| API | `backend/main.py` | `tests/test_api.py` |

## Create a controlled demo commit

From the repository root, create a small marker in the matching real source
file, review it, add an actual code change if desired, and commit it:

```powershell
.\scripts\new_demo_change.ps1 -Area preprocessing -Message "document encoder assumption"
git diff -- backend/preprocess.py
python -m pytest
git add backend/preprocess.py
git commit -m "Adjust preprocessing behavior"
```

Use `validation`, `preprocessing`, `prediction`, or `api` for `-Area`. The
helper only creates a visible source comment; it never fakes a model result or a
test result. Each commit should be reviewed and should contain a genuine code or
documentation adjustment appropriate to the selected area.
