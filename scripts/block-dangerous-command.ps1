param(
    [string]$CommandText = ""
)

$ErrorActionPreference = "Stop"

$blockedPatterns = @(
    'rm\s+-rf\s+[/~]',
    'git\s+push\s+--force',
    'git\s+reset\s+--hard',
    'Remove-Item\s+.*-Recurse\s+.*-Force'
)

foreach ($pattern in $blockedPatterns) {
    if ($CommandText -match $pattern) {
        Write-Error "Blocked dangerous command: $CommandText"
        exit 2
    }
}

exit 0