$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$reportDir = ".\.claude\reports"
$reportPath = Join-Path $reportDir "validation-status.json"
$rawLogPath = Join-Path $reportDir "validation-raw.log"

if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

if (Test-Path $rawLogPath) {
    Remove-Item $rawLogPath -Force
}

$jbrCandidates = @(
    "C:\Program Files\Android\Android Studio\jbr",
    "C:\Program Files\Android\Android Studio1\jbr"
)

foreach ($candidate in $jbrCandidates) {
    if (Test-Path $candidate) {
        $env:JAVA_HOME = $candidate
        $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
        break
    }
}

$startedAt = [DateTimeOffset]::Now

function Write-ValidationLogLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    Add-Content -Path $rawLogPath -Value $Line -Encoding UTF8
    Write-Host $Line
}

function Get-TaskOutcome {
    param(
        [string[]]$Lines = @(),

        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    $normalizedLines = @($Lines)

    if ($normalizedLines.Count -eq 0) {
        return "UNKNOWN"
    }

    $prefix = "> Task $TaskName"

    foreach ($line in $normalizedLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        if ($line -like "$prefix*") {
            if ($line -match "UP-TO-DATE") { return "UP_TO_DATE" }
            if ($line -match "FROM-CACHE") { return "FROM_CACHE" }
            if ($line -match "NO-SOURCE") { return "NO_SOURCE" }
            return "EXECUTED"
        }
    }

    return "UNKNOWN"
}

function Invoke-ValidationStep {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$TaskName,

        [Parameter(Mandatory = $true)]
        [string[]]$Command
    )

    Write-ValidationLogLine "== $Name =="

    $stepStartedAt = [DateTimeOffset]::Now

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Command[0]
    $psi.Arguments = (($Command | Select-Object -Skip 1) -join " ")
    $psi.WorkingDirectory = (Get-Location).Path
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    [void]$process.Start()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()

    $process.WaitForExit()

    $lines = @()

    if (-not [string]::IsNullOrWhiteSpace($stdout)) {
        $lines += @($stdout -split "`r?`n")
    }

    if (-not [string]::IsNullOrWhiteSpace($stderr)) {
        $lines += @($stderr -split "`r?`n")
    }

    $lines = @(
        $lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )

    foreach ($line in $lines) {
        Write-ValidationLogLine $line
    }

    $stepFinishedAt = [DateTimeOffset]::Now
    $exitCode = $process.ExitCode
    $taskOutcome = Get-TaskOutcome -Lines @($lines) -TaskName $TaskName

    return [ordered]@{
        status       = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
        command      = ($Command -join " ")
        exit_code    = $exitCode
        started_at   = $stepStartedAt.ToString("o")
        finished_at  = $stepFinishedAt.ToString("o")
        duration_ms  = [int][Math]::Round(($stepFinishedAt - $stepStartedAt).TotalMilliseconds)
        task_outcome = $taskOutcome
    }
}

$compileCommand = @(".\gradlew.bat", ":app:compileDebugKotlin", "--rerun-tasks", "--no-build-cache", "--console=plain")
$testsCommand   = @(".\gradlew.bat", ":app:testDebugUnitTest", "--rerun-tasks", "--no-build-cache", "--console=plain")
$detektCommand  = @(".\gradlew.bat", ":app:detekt", "--rerun-tasks", "--no-build-cache", "--console=plain")

$compile = $null
$tests = $null
$detekt = $null
$overall = "FAIL"

try {
    $compile = Invoke-ValidationStep -Name "compile" -TaskName ":app:compileDebugKotlin" -Command $compileCommand
    if ($compile.status -ne "PASS") {
        throw "Compile step failed."
    }

    $tests = Invoke-ValidationStep -Name "tests" -TaskName ":app:testDebugUnitTest" -Command $testsCommand
    if ($tests.status -ne "PASS") {
        throw "Tests step failed."
    }

    $detekt = Invoke-ValidationStep -Name "detekt" -TaskName ":app:detekt" -Command $detektCommand
    if ($detekt.status -ne "PASS") {
        throw "Detekt step failed."
    }

    $overall = "PASS"
}
finally {
    $finishedAt = [DateTimeOffset]::Now

    if ($null -eq $compile) {
        $compile = [ordered]@{
            status       = "NOT_RUN"
            command      = ($compileCommand -join " ")
            exit_code    = -1
            started_at   = $null
            finished_at  = $null
            duration_ms  = 0
            task_outcome = "UNKNOWN"
        }
    }

    if ($null -eq $tests) {
        $tests = [ordered]@{
            status       = "NOT_RUN"
            command      = ($testsCommand -join " ")
            exit_code    = -1
            started_at   = $null
            finished_at  = $null
            duration_ms  = 0
            task_outcome = "UNKNOWN"
        }
    }

    if ($null -eq $detekt) {
        $detekt = [ordered]@{
            status       = "NOT_RUN"
            command      = ($detektCommand -join " ")
            exit_code    = -1
            started_at   = $null
            finished_at  = $null
            duration_ms  = 0
            task_outcome = "UNKNOWN"
        }
    }

    $summary =
        if ($overall -eq "PASS") {
            "All canonical validation steps passed."
        } else {
            "One or more canonical validation steps failed."
        }

    $payload = [ordered]@{
        timestamp      = $finishedAt.ToString("o")
        started_at     = $startedAt.ToString("o")
        finished_at    = $finishedAt.ToString("o")
        duration_ms    = [int][Math]::Round(($finishedAt - $startedAt).TotalMilliseconds)
        generator      = "scripts/validate.ps1"
        schema_version = 3

        compile        = $compile.status
        tests          = $tests.status
        detekt         = $detekt.status
        overall        = $overall
        summary        = $summary
        raw_log_path   = ".\.claude\reports\validation-raw.log"

        steps = [ordered]@{
            compile = $compile
            tests   = $tests
            detekt  = $detekt
        }
    }

    $payload | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8

    Write-ValidationLogLine "Validation report written to $reportPath"
    Write-ValidationLogLine "Validation raw log written to $rawLogPath"
}

if ($overall -ne "PASS") {
    exit 1
}

exit 0