param(
    [string]$Module = "app"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ReportsDir = Join-Path $RepoRoot ".claude\reports"
$ModuleStatusPath = Join-Path $ReportsDir "validation-module-status.json"
$ModuleLogPath = Join-Path $ReportsDir "validation-module.log"

function Write-Info([string]$message) {
    Write-Host "[validate-module] $message"
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
    Add-Content -Path $ModuleLogPath -Value "[$($stepStart.ToString("o"))] START $Name"
    Add-Content -Path $ModuleLogPath -Value $CommandLine

    Push-Location $WorkingDirectory
    try {
        $output = cmd.exe /c $CommandLine 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    foreach ($line in $output) {
        Add-Content -Path $ModuleLogPath -Value $line
    }

    $stepEnd = Get-Date
    Add-Content -Path $ModuleLogPath -Value "[$($stepEnd.ToString("o"))] END $Name (exit=$exitCode)"

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

function Build-GradleCommand([string]$taskPath) {
    return ".\gradlew.bat $taskPath --rerun-tasks --no-build-cache --console=plain"
}

function Write-Report {
    param(
        [datetime]$StartedAt,
        [datetime]$FinishedAt,
        [object[]]$Steps,
        [string]$TargetModule
    )

    $overall = if (($Steps | Where-Object { $_.status -eq "FAIL" }).Count -gt 0) { "FAIL" } else { "PASS" }

    $summary = if ($overall -eq "PASS") {
        "Scoped validation passed for module '$TargetModule'."
    } else {
        "Scoped validation failed for module '$TargetModule'. See validation-module.log for details."
    }

    $report = [ordered]@{
        timestamp = $FinishedAt.ToString("o")
        started_at = $StartedAt.ToString("o")
        finished_at = $FinishedAt.ToString("o")
        duration_ms = [int][Math]::Round(($FinishedAt - $StartedAt).TotalMilliseconds)
        generator = "scripts/validate-module.ps1"
        schema_version = 1
        module = $TargetModule
        overall = $overall
        summary = $summary
        raw_log_path = ".\.claude\reports\validation-module.log"
        steps = $Steps
    }

    $json = $report | ConvertTo-Json -Depth 8
    Set-Content -Path $ModuleStatusPath -Value $json -Encoding UTF8
}

function Main {
    Ensure-ReportsDir
    Set-Content -Path $ModuleLogPath -Value ""

    $startedAt = Get-Date
    Write-Info "Running scoped validation for module '$Module'."

    $env:JAVA_HOME = Get-JbrPath

    $capitalized = $Module.Substring(0,1).ToUpper() + $Module.Substring(1)

    $compileTask = ":$Module:compileDebugKotlin"
    $testTask = ":$Module:testDebugUnitTest"
    $detektTask = ":$Module:detekt"

    $steps = @()

    $steps += Invoke-LoggedCommand `
        -Name "compile" `
        -CommandLine (Build-GradleCommand $compileTask) `
        -WorkingDirectory $RepoRoot

    if ($steps[-1].status -eq "PASS") {
        $steps += Invoke-LoggedCommand `
            -Name "tests" `
            -CommandLine (Build-GradleCommand $testTask) `
            -WorkingDirectory $RepoRoot
    }
    else {
        $steps += [pscustomobject]@{
            name = "tests"
            status = "NOT_RUN"
            exit_code = -1
            started_at = $null
            finished_at = $null
            duration_ms = 0
            command = Build-GradleCommand $testTask
        }
    }

    if ($steps[0].status -eq "PASS" -and $steps[1].status -eq "PASS") {
        $steps += Invoke-LoggedCommand `
            -Name "detekt" `
            -CommandLine (Build-GradleCommand $detektTask) `
            -WorkingDirectory $RepoRoot
    }
    else {
        $steps += [pscustomobject]@{
            name = "detekt"
            status = "NOT_RUN"
            exit_code = -1
            started_at = $null
            finished_at = $null
            duration_ms = 0
            command = Build-GradleCommand $detektTask
        }
    }

    $finishedAt = Get-Date
    Write-Report -StartedAt $startedAt -FinishedAt $finishedAt -Steps $steps -TargetModule $Module

    if (($steps | Where-Object { $_.status -eq "FAIL" }).Count -gt 0) {
        Write-Info "Scoped validation failed."
        exit 1
    }

    Write-Info "Scoped validation passed."
}

Main