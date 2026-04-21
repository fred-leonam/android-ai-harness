Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot

function Write-Info([string]$message) {
    Write-Host "[format] $message"
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
        Write-Info "Unable to determine changed files from git. Skipping targeted formatting."
        return @()
    }
}

function Resolve-FullPath([string]$relativePath) {
    return Join-Path $RepoRoot $relativePath
}

function Normalize-KotlinFile([string]$path) {
    if (-not (Test-Path $path)) {
        return
    }

    $original = Get-Content -Raw -Path $path
    $normalized = $original -replace "`r?`n", "`r`n"

    # Trim trailing spaces/tabs at line ends
    $normalized = [regex]::Replace($normalized, "[\t ]+\r\n", "`r`n")

    # Ensure single trailing newline
    $normalized = $normalized.TrimEnd("`r", "`n") + "`r`n"

    if ($normalized -ne $original) {
        Set-Content -Path $path -Value $normalized -NoNewline
        Write-Info "Normalized whitespace: $path"
    }
}

function Main {
    Write-Info "Starting lightweight formatting."

    $changedFiles = Get-GitChangedFiles
    if ($changedFiles.Count -eq 0) {
        Write-Info "No changed files detected. Nothing to format."
        return
    }

    $targets = @(
        $changedFiles |
        Where-Object {
            $_ -match '\.kt$' -or
            $_ -match '\.kts$' -or
            $_ -match '\.md$'
        }
    )

    if ($targets.Count -eq 0) {
        Write-Info "No Kotlin, Gradle Kotlin, or Markdown files changed."
        return
    }

    foreach ($relativePath in $targets) {
        $fullPath = Resolve-FullPath $relativePath
        Normalize-KotlinFile -path $fullPath
    }

    Write-Info "Formatting pass completed."
}

Main