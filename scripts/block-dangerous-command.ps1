param(
    [string]$CommandText = ""
)

$ErrorActionPreference = "Stop"

$blockedPatterns = @(
    'rm\s+-rf\s+[/~]',
    'git\s+push\s+--force',
    'git\s+reset\s+--hard',
    'Remove-Item\s+.*-Recurse\s+.*-Force',
    'gradlew\.bat\s+',
    'scripts\\write-validation-report\.ps1',
    'Set-Content\s+.*validation-status\.json',
    'Add-Content\s+.*validation-status\.json',
    'Out-File\s+.*validation-status\.json',
    'Copy-Item\s+.*validation-status\.json',
    'Move-Item\s+.*validation-status\.json'
)

foreach ($pattern in $blockedPatterns) {
    if ($CommandText -match $pattern) {
        Write-Error "Blocked dangerous or policy-breaking command: $CommandText"
        exit 2
    }
}

exit 0