param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("validation", "preprocessing", "prediction", "api")]
    [string]$Area,
    [Parameter(Mandatory = $true)]
    [string]$Message
)

# Creates a small, honest source-code marker for a controlled CI demonstration.
# Review the resulting diff, then make a real implementation change before committing.
$paths = @{
    validation = "backend/preprocess.py"
    preprocessing = "backend/preprocess.py"
    prediction = "backend/predict.py"
    api = "backend/main.py"
}

$path = $paths[$Area]
Add-Content -Path $path -Value "`n# Demo change note ($Area): $Message"
Write-Host "Updated $path. Review it with: git diff -- $path"
Write-Host "Run tests with: python -m pytest"
