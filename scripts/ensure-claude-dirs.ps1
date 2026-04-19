$ErrorActionPreference = "Stop"

$dirs = @(
    ".\.claude",
    ".\.claude\reports"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "Claude directories ensured."
exit 0