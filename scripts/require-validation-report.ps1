param(
    [string]$ClaudeToolInput = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ReportsDir = Join-Path $RepoRoot ".claude\reports"
$CanonicalStatusPath = Join-Path $ReportsDir "validation-status.json"

function Write-Info([string]$message) {
    Write-Host "[require-validation-report] $message"
}

function Fail([string]$message) {
    Write-Error $message
    exit 1
}

function Get-GitChangedFiles {
    try {
        Push-Location $RepoRoot
        $output = git diff --name-only --diff-filter=ACMR HEAD 2>$null
        Pop-Location

        if (-not $output) {
            return @()
        }

        return @($output | Where-Object { $_ -and $_.Trim().Length -gt 0 })
    }
    catch {
        try { Pop-Location } catch {}
        return @()
    }
}

function Get-ChangedProductionFiles {
    $changed = Get-GitChangedFiles

    return @(
        $changed | Where-Object {
            $_ -match '^(app|config)/' -or
            $_ -eq 'build.gradle.kts' -or
            $_ -eq 'settings.gradle.kts' -or
            $_ -eq 'gradle.properties' -or
            $_ -eq 'local.properties'
        }
    )
}

function Get-ChangedOnlyDocsOrReports {
    $changed = Get-GitChangedFiles
    if ($changed.Count -eq 0) {
        return $false
    }

    $nonDocFiles = @(
        $changed | Where-Object {
            ($_ -notmatch '^docs/') -and
            ($_ -notmatch '\.md$') -and
            ($_ -notmatch '^\.claude/reports/')
        }
    )

    return $nonDocFiles.Count -eq 0
}

function Parse-JsonFile([string]$path) {
    if (-not (Test-Path $path)) {
        return $null
    }

    $raw = Get-Content -Raw -Path $path
    if (-not $raw -or $raw.Trim().Length -eq 0) {
        return $null
    }

    return $raw | ConvertFrom-Json
}

function Is-ReviewOrDiagnosisOnlySession([string]$toolInput) {
    if (-not $toolInput) {
        return $false
    }

    $normalized = $toolInput.ToLowerInvariant()

    $reviewHints = @(
        "review-only",
        "review only",
        "diagnosis-only",
        "diagnosis only",
        "analyze only",
        "analysis only",
        "no code change",
        "no-code-change"
    )

    foreach ($hint in $reviewHints) {
        if ($normalized.Contains($hint)) {
            return $true
        }
    }

    return $false
}

function Assert-CanonicalReportShape($report) {
    $requiredTopLevel = @(
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

    foreach ($field in $requiredTopLevel) {
        if (-not ($report.PSObject.Properties.Name -contains $field)) {
            Fail "Canonical validation report is missing required field '$field'."
        }
    }

    if ($report.generator -ne "scripts/validate.ps1") {
        Fail "Canonical validation report generator must be 'scripts/validate.ps1'."
    }

    foreach ($stepName in @("compile", "tests", "detekt")) {
        if (-not ($report.steps.PSObject.Properties.Name -contains $stepName)) {
            Fail "Canonical validation report is missing steps.$stepName."
        }
    }
}

function Assert-CanonicalReportFreshEnough($report) {
    $finishedAt = $null
    try {
        $finishedAt = [datetime]::Parse($report.finished_at)
    }
    catch {
        Fail "Canonical validation report has invalid finished_at."
    }

    $age = (Get-Date) - $finishedAt
    if ($age.TotalHours -gt 12) {
        Fail "Canonical validation report is stale (older than 12 hours). Re-run validate.ps1."
    }
}

function Assert-CanonicalPass($report) {
    if ($report.overall -ne "PASS") {
        Fail "Canonical validation report exists but overall is not PASS."
    }

    foreach ($phase in @("compile", "tests", "detekt")) {
        $value = $report.$phase
        if ($value -ne "PASS") {
            Fail "Canonical validation phase '$phase' is not PASS."
        }
    }
}

function Main {
    $changedProductionFiles = Get-ChangedProductionFiles

    if ($changedProductionFiles.Count -eq 0) {
        if (Get-ChangedOnlyDocsOrReports) {
            Write-Info "Only docs/report files changed. Canonical validation not required."
            return
        }

        if (Is-ReviewOrDiagnosisOnlySession -toolInput $ClaudeToolInput) {
            Write-Info "Review/diagnosis-only session detected. Canonical validation not required."
            return
        }

        Write-Info "No production files changed. Canonical validation not required."
        return
    }

    Write-Info "Production-relevant files changed. Canonical validation is required."

    $report = Parse-JsonFile -path $CanonicalStatusPath
    if ($null -eq $report) {
        Fail "Missing canonical validation report at .claude/reports/validation-status.json."
    }

    Assert-CanonicalReportShape $report
    Assert-CanonicalReportFreshEnough $report
    Assert-CanonicalPass $report

    Write-Info "Canonical validation report is present, well-formed, fresh, and passing."
}

Main