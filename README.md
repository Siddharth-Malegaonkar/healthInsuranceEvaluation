# Health Insurance Premium Predictor

This repository contains a Flutter client and a Python/FastAPI backend that
predicts health-insurance premiums with the included trained model artifact.

## Backend development and CI

Install the Python dependencies from the repository root:

```powershell
python -m pip install -r backend/requirements.txt
```

Run the backend test suite locally:

```powershell
python -m pytest
```

GitHub Actions runs this same command on every push to `main` and every pull
request targeting `main`. The workflow is CI-only: it installs dependencies and
reports the pytest result; it does not deploy the application.

To make a small test code change and trigger the workflow after you push:

```powershell
.\scripts\new_demo_change.ps1 -Area preprocessing -Message "demo preprocessing change"
python -m pytest
git add backend/preprocess.py
git commit -m "Demo preprocessing change"
git push origin main
```

The backend tests are intentionally grouped by validation, preprocessing,
prediction/model behavior, and API behavior. A future external **Adaptive Test
Selection using ML + Contextual Bandits** system can use this file-to-test
relationship and the resulting Git history to learn which tests are most useful
for a changed area. See [the demo guide](docs/adaptive-test-selection-demo.md)
for the change-to-test mapping.
