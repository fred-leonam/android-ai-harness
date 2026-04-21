Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ReportsDir = Join-Path $RepoRoot ".claude\reports"
$FastStatusPath = Join-Path $ReportsDir "validation-fast-status.json"
$FastLogPath = Join-Path $ReportsDir "validation-fast.log"

function Write-Info([string]$message) {
    Write-Host "[validate-fast] $message"
}

function Ensure-ReportsDir {
    if (-not (Test-Path $ReportsDir)) {
        New-Item -ItemType Directory -Path $ReportsDir -Force | Out-Null
    }
}

function Get-JbrPath {
    $candidates = @(
        "C:\Program Files\Android\Android Studio\jbr",
        "C:\Program Files\Android\Android Studio1\jbr"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Invoke-LoggedCommand {
    param(
        [string]$Name,
        [string]$CommandLine,
        [string]$WorkingDirectory
    )

    $stepStart = Get-Date
    Add-Content -Path $FastLogPath -Value "[$($stepStart.ToString("o"))] START $Name"
    Add-Content -Path $FastLogPath -Value $CommandLine

    Push-Location $WorkingDirectory
    try {
        $output = cmd.exe /c $CommandLine 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    foreach ($line in $output) {
        Add-Content -Path $FastLogPath -Value $line
    }

    $stepEnd = Get-Date
    Add-Content -Path $FastLogPath -Value "[$($stepEnd.ToString("o"))] END $Name (exit=$exitCode)"

    return [pscustomobject]@{
        name = $Name
        status = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
        exit_code = $exitCode
        started_at = $stepStart.ToString("o")
        finished_at = $stepEnd.ToString("o")
        duration_ms = [int][Math]::Round(($stepEnd - $stepStart).TotalMilliseconds)
        command = $CommandLine
    }
}

function Write-Report {
    param(
        [datetime]$StartedAt,
        [datetime]$FinishedAt,
        [object[]]$Steps
    )

    $overall = if (($Steps | Where-Object { $_.status -eq "FAIL" }).Count -gt 0) { "FAIL" } else { "PASS" }

    $summary = if ($overall -eq "PASS") {
        "Fast validation passed."
    } else {
        "Fast validation failed. See validation-fast.log for details."
    }

    $report = [ordered]@{
        timestamp = $FinishedAt.ToString("o")
        started_at = $StartedAt.ToString("o")
        finished_at = $FinishedAt.ToString("o")
        duration_ms = [int][Math]::Round(($FinishedAt - $StartedAt).TotalMilliseconds)
        generator = "scripts/validate-fast.ps1"
        schema_version = 1
        overall = $overall
        summary = $summary
        raw_log_path = ".\.claude\reports\validation-fast.log"
        steps = $Steps
    }

    $json = $report | ConvertTo-Json -Depth 8
    Set-Content -Path $FastStatusPath -Value $json -Encoding UTF8
}

function Main {
    Ensure-ReportsDir
    Set-Content -Path $FastLogPath -Value ""

    $startedAt = Get-Date
    Write-Info "Running fast validation."

    $env:JAVA_HOME = Get-JbrPath

    $steps = @()

    $steps += Invoke-LoggedCommand `
        -Name "compile" `
        -CommandLine ".\gradlew.bat :app:compileDebugKotlin --console=plain" `
        -WorkingDirectory $RepoRoot

    $finishedAt = Get-Date
    Write-Report -StartedAt $startedAt -FinishedAt $finishedAt -Steps $steps

    if (($steps | Where-Object { $_.status -eq "FAIL" }).Count -gt 0) {
        Write-Info "Fast validation failed."
        exit 1
    }

    Write-Info "Fast validation passed."
}

Main