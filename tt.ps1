[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateRange(1, 100)]
    [int]$Opacity,

    [Parameter()]
    [string]$SettingsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$defaultTransparentOpacity = 8
$solidOpacity = 100

function Set-ObjectProperty {
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Value
    )

    if ($InputObject.PSObject.Properties[$Name]) {
        $InputObject.$Name = $Value
    }
    else {
        $InputObject | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $settingsCandidates = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )

    $SettingsPath = $settingsCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}

if ([string]::IsNullOrWhiteSpace($SettingsPath) -or -not (Test-Path -LiteralPath $SettingsPath)) {
    throw 'Windows Terminal settings.json was not found. Open Windows Terminal once, then try again.'
}

try {
    $settings = Get-Content -LiteralPath $SettingsPath -Raw | ConvertFrom-Json
}
catch {
    throw "Could not read Windows Terminal settings. Restore '$SettingsPath.tt-backup' if needed. $($_.Exception.Message)"
}

if (-not $settings.PSObject.Properties['profiles']) {
    Set-ObjectProperty -InputObject $settings -Name 'profiles' -Value ([pscustomobject]@{})
}

if (-not $settings.profiles.PSObject.Properties['defaults']) {
    Set-ObjectProperty -InputObject $settings.profiles -Name 'defaults' -Value ([pscustomobject]@{})
}

$currentOpacity = if ($settings.profiles.defaults.PSObject.Properties['opacity']) {
    [int]$settings.profiles.defaults.opacity
}
else {
    $solidOpacity
}

$newOpacity = if ($PSBoundParameters.ContainsKey('Opacity')) {
    $Opacity
}
elseif ($currentOpacity -lt $solidOpacity) {
    $solidOpacity
}
else {
    $defaultTransparentOpacity
}

$backupPath = "$SettingsPath.tt-backup"
if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $SettingsPath -Destination $backupPath
}

Set-ObjectProperty -InputObject $settings.profiles.defaults -Name 'opacity' -Value $newOpacity
Set-ObjectProperty -InputObject $settings.profiles.defaults -Name 'useAcrylic' -Value $false

$json = $settings | ConvertTo-Json -Depth 100
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($SettingsPath, $json, $utf8WithoutBom)

if ($newOpacity -eq $solidOpacity) {
    Write-Host 'Terminal transparency: OFF (solid)' -ForegroundColor Cyan
}
else {
    Write-Host "Terminal transparency: $newOpacity% opacity" -ForegroundColor Cyan
}

