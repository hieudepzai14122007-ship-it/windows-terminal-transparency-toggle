[CmdletBinding()]
param(
    [ValidateRange(1, 100)]
    [int]$DefaultOpacity = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourceScript = Join-Path $PSScriptRoot 'tt.ps1'
if (-not (Test-Path -LiteralPath $sourceScript)) {
    throw 'tt.ps1 must be in the same directory as install.ps1. Clone or download the complete repository first.'
}

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\TerminalTransparencyToggle'
$installedScript = Join-Path $installDirectory 'tt.ps1'
New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
Copy-Item -LiteralPath $sourceScript -Destination $installedScript -Force

$documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$profilePaths = @(
    (Join-Path $documents 'WindowsPowerShell\profile.ps1'),
    (Join-Path $documents 'PowerShell\profile.ps1')
)

$startMarker = '# >>> terminal-transparency-toggle >>>'
$endMarker = '# <<< terminal-transparency-toggle <<<'
$profileBlock = @"
$startMarker
function tt { & (Join-Path `$env:LOCALAPPDATA 'Programs\TerminalTransparencyToggle\tt.ps1') @args }
$endMarker
"@

foreach ($profilePath in $profilePaths) {
    $profileDirectory = Split-Path -Parent $profilePath
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null

    $existingContent = if (Test-Path -LiteralPath $profilePath) {
        Get-Content -LiteralPath $profilePath -Raw
    }
    else {
        ''
    }

    $escapedStart = [regex]::Escape($startMarker)
    $escapedEnd = [regex]::Escape($endMarker)
    $cleanContent = [regex]::Replace($existingContent, "(?ms)^$escapedStart\r?\n.*?^$escapedEnd\r?\n?", '').TrimEnd()
    $newContent = if ([string]::IsNullOrWhiteSpace($cleanContent)) {
        "$profileBlock`r`n"
    }
    else {
        "$cleanContent`r`n`r`n$profileBlock`r`n"
    }

    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($profilePath, $newContent, $utf8WithoutBom)
}

& $installedScript $DefaultOpacity

Write-Host ''
Write-Host 'Installed Terminal Transparency Toggle.' -ForegroundColor Green
Write-Host 'Open a new PowerShell window, then run: tt 8' -ForegroundColor Cyan

