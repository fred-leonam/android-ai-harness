$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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

$requiredProps = @(
    "timestamp",
    "started_at",
    "finished_at",
    "duration_ms",
    "generator",
    "schema_version",
    "compile",
    "tests",
    "detekt",
    "overall",
    "summary",
    "raw_log_path",
    "steps"
)

foreach ($prop in $requiredProps) {
    if (-not ($report.PSObject.Properties.Name -contains $prop)) {
        Write-Host "Blocking stop: validation report is missing required property '$prop'"
        exit 2
    }
}

if ([string]$report.generator -ne "scripts/validate.ps1") {
    Write-Host "Blocking stop: validation report generator must be 'scripts/validate.ps1'"
    exit 2
}

if ([int]$report.schema_version -ne 3) {
    Write-Host "Blocking stop: validation report schema_version must be 3"
    exit 2
}

$allowedPhaseValues = @("PASS", "FAIL", "NOT_RUN")
foreach ($prop in @("compile", "tests", "detekt")) {
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

if ([string]::IsNullOrWhiteSpace([string]$report.summary)) {
    Write-Host "Blocking stop: validation summary is empty"
    exit 2
}

try {
    $timestamp = [DateTimeOffset]::Parse($report.timestamp)
    $startedAt = [DateTimeOffset]::Parse($report.started_at)
    $finishedAt = [DateTimeOffset]::Parse($report.finished_at)
} catch {
    Write-Host "Blocking stop: validation timestamps are invalid"
    exit 2
}

if ($finishedAt -lt $startedAt) {
    Write-Host "Blocking stop: finished_at is earlier than started_at"
    exit 2
}

if ([int]$report.duration_ms -lt 0) {
    Write-Host "Blocking stop: duration_ms must be non-negative"
    exit 2
}

$expectedRawLogPath = ".\.claude\reports\validation-raw.log"
if ([string]$report.raw_log_path -ne $expectedRawLogPath) {
    Write-Host "Blocking stop: raw_log_path must be '$expectedRawLogPath'"
    exit 2
}

if (-not (Test-Path $report.raw_log_path)) {
    Write-Host "Blocking stop: validation raw log is missing at $($report.raw_log_path)"
    exit 2
}

$expectedCommands = @{
    compile = ".\gradlew.bat :app:compileDebugKotlin --rerun-tasks --no-build-cache --console=plain"
    tests   = ".\gradlew.bat :app:testDebugUnitTest --rerun-tasks --no-build-cache --console=plain"
    detekt  = ".\gradlew.bat :app:detekt --rerun-tasks --no-build-cache --console=plain"
}

$allowedTaskOutcomes = @("EXECUTED", "UP_TO_DATE", "FROM_CACHE", "NO_SOURCE", "UNKNOWN")

foreach ($stepName in @("compile", "tests", "detekt")) {
    if (-not ($report.steps.PSObject.Properties.Name -contains $stepName)) {
        Write-Host "Blocking stop: steps.$stepName is missing"
        exit 2
    }

    $step = $report.steps.$stepName

    foreach ($requiredStepProp in @("status", "command", "exit_code", "started_at", "finished_at", "duration_ms", "task_outcome")) {
        if (-not ($step.PSObject.Properties.Name -contains $requiredStepProp)) {
            Write-Host "Blocking stop: steps.$stepName.$requiredStepProp is missing"
            exit 2
        }
    }

    if ([string]$step.command -ne $expectedCommands[$stepName]) {
        Write-Host "Blocking stop: unexpected command for steps.$stepName"
        exit 2
    }

    if ([string]$step.status -ne [string]$report.$stepName) {
        Write-Host "Blocking stop: steps.$stepName.status does not match top-level $stepName"
        exit 2
    }

    if ($allowedTaskOutcomes -notcontains [string]$step.task_outcome) {
        Write-Host "Blocking stop: invalid task_outcome for steps.$stepName"
        exit 2
    }

    if ([string]$step.status -eq "PASS" -and [int]$step.exit_code -ne 0) {
        Write-Host "Blocking stop: PASS step '$stepName' must have exit_code 0"
        exit 2
    }

    if ([string]$step.status -eq "FAIL" -and [int]$step.exit_code -eq 0) {
        Write-Host "Blocking stop: FAIL step '$stepName' cannot have exit_code 0"
        exit 2
    }

    if ([string]$step.status -eq "NOT_RUN" -and [int]$step.exit_code -ne -1) {
        Write-Host "Blocking stop: NOT_RUN step '$stepName' must have exit_code -1"
        exit 2
    }

    if ([string]$step.status -ne "NOT_RUN") {
        try {
            $null = [DateTimeOffset]::Parse($step.started_at)
            $null = [DateTimeOffset]::Parse($step.finished_at)
        } catch {
            Write-Host "Blocking stop: timestamps for executed step '$stepName' are invalid"
            exit 2
        }
    }
}

if (
    $report.compile -eq "PASS" -and
    $report.tests -eq "PASS" -and
    $report.detekt -eq "PASS" -and
    $report.overall -ne "PASS"
) {
    Write-Host "Blocking stop: overall must be PASS when all phases pass"
    exit 2
}

if (
    ($report.compile -ne "PASS" -or $report.tests -ne "PASS" -or $report.detekt -ne "PASS") -and
    $report.overall -ne "FAIL"
) {
    Write-Host "Blocking stop: overall must be FAIL when any phase is not PASS"
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

$rawLog = Get-Content $report.raw_log_path -Raw

foreach ($requiredLogMarker in @(
    "== compile ==",
    "== tests ==",
    "== detekt ==",
    "Validation report written to .\.claude\reports\validation-status.json"
)) {
    if ($rawLog -notmatch [Regex]::Escape($requiredLogMarker)) {
        Write-Host "Blocking stop: raw log is missing expected marker '$requiredLogMarker'"
        exit 2
    }
}

Write-Host "Validation gate check passed."
exit 0