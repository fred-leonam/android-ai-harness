$ErrorActionPreference = "Stop"

$reportPath = ".\.claude\reports\validation-status.json"

if (-not (Test-Path $reportPath)) {
    Write-Host "Blocking stop: validation report is missing at $reportPath"
    exit 2
}

try {
    $raw = Get-Content $reportPath -Raw
    $report = $raw | ConvertFrom-Json
} catch {
    Write-Host "Blocking stop: validation report is unreadable or invalid JSON at $reportPath"
    exit 2
}

$requiredProps = @("timestamp", "compile", "tests", "detekt", "overall", "summary")

foreach ($prop in $requiredProps) {
    if (-not ($report.PSObject.Properties.Name -contains $prop)) {
        Write-Host "Blocking stop: validation report is missing required property '$prop'"
        exit 2
    }
}

$allowedPhaseValues = @("PASS", "FAIL", "NOT_RUN")
$phaseProps = @("compile", "tests", "detekt")

foreach ($prop in $phaseProps) {
    $value = [string]$report.$prop
    if ($allowedPhaseValues -notcontains $value) {
        Write-Host "Blocking stop: validation report property '$prop' has invalid value '$value'"
        exit 2
    }
}

$overall = [string]$report.overall
if (@("PASS", "FAIL") -notcontains $overall) {
    Write-Host "Blocking stop: validation report property 'overall' has invalid value '$overall'"
    exit 2
}

$summary = [string]$report.summary
if ([string]::IsNullOrWhiteSpace($summary)) {
    Write-Host "Blocking stop: validation summary is empty"
    exit 2
}

try {
    $timestamp = [DateTimeOffset]::Parse($report.timestamp)
} catch {
    Write-Host "Blocking stop: validation timestamp is invalid"
    exit 2
}

$repoRoot = Get-Location
$excludedRoots = @(
    (Join-Path $repoRoot ".git"),
    (Join-Path $repoRoot ".claude"),
    (Join-Path $repoRoot "build")
)

$latestCodeWrite = Get-ChildItem -Path $repoRoot -Recurse -File |
    Where-Object {
        $full = $_.FullName
        -not ($excludedRoots | ForEach-Object { $full.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) } | Where-Object { $_ } | Select-Object -First 1)
    } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1

if ($null -ne $latestCodeWrite) {
    $reportUtc = $timestamp.UtcDateTime
    $latestWriteUtc = $latestCodeWrite.LastWriteTimeUtc

    if ($reportUtc -lt $latestWriteUtc) {
        Write-Host "Blocking stop: validation report is stale relative to repository changes"
        Write-Host "Latest file: $($latestCodeWrite.FullName)"
        Write-Host "Latest write (UTC): $latestWriteUtc"
        Write-Host "Report time (UTC): $reportUtc"
        exit 2
    }
}

Write-Host "Validation gate check passed."
exit 0