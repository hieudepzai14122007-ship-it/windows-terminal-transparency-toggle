[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$documents = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)
$profilePaths = @(
    (Join-Path $documents 'WindowsPowerShell\profile.ps1'),
    (Join-Path $documents 'PowerShell\profile.ps1')
)

$startMarker = '# >>> terminal-transparency-toggle >>>'
$endMarker = '# <<< terminal-transparency-toggle <<<'
$escapedStart = [regex]::Escape($startMarker)
$escapedEnd = [regex]::Escape($endMarker)

foreach ($profilePath in $profilePaths) {
    if (-not (Test-Path -LiteralPath $profilePath)) {
        continue
    }

    $existingContent = Get-Content -LiteralPath $profilePath -Raw
    $newContent = [regex]::Replace($existingContent, "(?ms)^$escapedStart\r?\n.*?^$escapedEnd\r?\n?", '').TrimEnd()
    if ($newContent.Length -gt 0) {
        $newContent += "`r`n"
    }

    $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($profilePath, $newContent, $utf8WithoutBom)
}

$installDirectory = Join-Path $env:LOCALAPPDATA 'Programs\TerminalTransparencyToggle'
if (Test-Path -LiteralPath $installDirectory) {
    Remove-Item -LiteralPath $installDirectory -Recurse -Force
}

Write-Host 'Uninstalled Terminal Transparency Toggle.' -ForegroundColor Green
Write-Host 'Your current Windows Terminal opacity was left unchanged.' -ForegroundColor Cyan

