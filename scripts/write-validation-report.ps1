param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("PASS", "FAIL", "NOT_RUN")]
    [string]$Compile,

    [Parameter(Mandatory = $true)]
    [ValidateSet("PASS", "FAIL", "NOT_RUN")]
    [string]$Tests,

    [Parameter(Mandatory = $true)]
    [ValidateSet("PASS", "FAIL", "NOT_RUN")]
    [string]$Detekt,

    [Parameter(Mandatory = $true)]
    [string]$Summary
)

$ErrorActionPreference = "Stop"

$reportDir = ".\.claude\reports"
$reportPath = Join-Path $reportDir "validation-status.json"

if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

$overall = if ($Compile -eq "PASS" -and $Tests -eq "PASS" -and $Detekt -eq "PASS") { "PASS" } else { "FAIL" }

$payload = [ordered]@{
    timestamp = [DateTimeOffset]::Now.ToString("o")
    compile   = $Compile
    tests     = $Tests
    detekt    = $Detekt
    overall   = $overall
    summary   = $Summary
}

$payload | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath -Encoding UTF8

Write-Host "Validation report written to $reportPath"
exit 0