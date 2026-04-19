$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$reportDir = ".\.claude\reports"
$reportPath = Join-Path $reportDir "validation-status.json"

if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

$jbrPath = "C:\Program Files\Android\Android Studio1\jbr"
if (Test-Path $jbrPath) {
    $env:JAVA_HOME = $jbrPath
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
}

$startedAt = [DateTimeOffset]::Now

function Invoke-ValidationStep {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string[]]$Command
    )

    Write-Host "== $Name =="

    $stepStartedAt = [DateTimeOffset]::Now
    $savedEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = & $Command[0] $Command[1..($Command.Length - 1)] 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $savedEAP
    $stepFinishedAt = [DateTimeOffset]::Now

    if ($null -ne $output) {
        $output | ForEach-Object { Write-Host ([string]$_) }
    }

    return [ordered]@{
        status       = if ($exitCode -eq 0) { "PASS" } else { "FAIL" }
        command      = ($Command -join " ")
        exit_code    = $exitCode
        started_at   = $stepStartedAt.ToString("o")
        finished_at  = $stepFinishedAt.ToString("o")
        duration_ms  = [int][Math]::Round(($stepFinishedAt - $stepStartedAt).TotalMilliseconds)
    }
}

$compile = $null
$tests = $null
$detekt = $null

try {
    $compile = Invoke-ValidationStep -Name "compile" -Command @(".\gradlew.bat", ":app:compileDebugKotlin")
    if ($compile.status -ne "PASS") {
        throw "Compile step failed."
    }

    $tests = Invoke-ValidationStep -Name "tests" -Command @(".\gradlew.bat", ":app:testDebugUnitTest", "--rerun-tasks")
    if ($tests.status -ne "PASS") {
        throw "Tests step failed."
    }

    $detekt = Invoke-ValidationStep -Name "detekt" -Command @(".\gradlew.bat", ":app:detekt")
    if ($detekt.status -ne "PASS") {
        throw "Detekt step failed."
    }
}
finally {
    $finishedAt = [DateTimeOffset]::Now

    if ($null -eq $compile) {
        $compile = [ordered]@{
            status      = "NOT_RUN"
            command     = ".\gradlew.bat :app:compileDebugKotlin"
            exit_code   = -1
            started_at  = $null
            finished_at = $null
            duration_ms = 0
        }
    }

    if ($null -eq $tests) {
        $tests = [ordered]@{
            status      = "NOT_RUN"
            command     = ".\gradlew.bat :app:testDebugUnitTest --rerun-tasks"
            exit_code   = -1
            started_at  = $null
            finished_at = $null
            duration_ms = 0
        }
    }

    if ($null -eq $detekt) {
        $detekt = [ordered]@{
            status      = "NOT_RUN"
            command     = ".\gradlew.bat :app:detekt"
            exit_code   = -1
            started_at  = $null
            finished_at = $null
            duration_ms = 0
        }
    }

    $overall = if (
        $compile.status -eq "PASS" -and
        $tests.status -eq "PASS" -and
        $detekt.status -eq "PASS"
    ) { "PASS" } else { "FAIL" }

    $summary =
        if ($overall -eq "PASS") {
            "All canonical validation steps passed."
        } else {
            "One or more canonical validation steps failed."
        }

    $payload = [ordered]@{
        timestamp     = $finishedAt.ToString("o")
        started_at    = $startedAt.ToString("o")
        finished_at   = $finishedAt.ToString("o")
        duration_ms   = [int][Math]::Round(($finishedAt - $startedAt).TotalMilliseconds)
        generator     = "scripts/validate.ps1"
        schema_version = 2

        compile       = $compile.status
        tests         = $tests.status
        detekt        = $detekt.status
        overall       = $overall
        summary       = $summary

        steps = [ordered]@{
            compile = $compile
            tests   = $tests
            detekt  = $detekt
        }
    }

    $payload | ConvertTo-Json -Depth 10 | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "Validation report written to $reportPath"
}

if ($overall -ne "PASS") {
    exit 1
}

exit 0