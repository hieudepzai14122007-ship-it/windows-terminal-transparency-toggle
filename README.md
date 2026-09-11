# Windows Terminal Transparency Toggle

A tiny PowerShell command for controlling Windows Terminal background opacity.

```powershell
tt 8
tt 35
tt 70
tt 100
```

Run `tt` without a number to toggle between 8% opacity and fully solid. The effect is unblurred transparency, and it applies to every Windows Terminal profile through `profiles.defaults`.

## Requirements

- Windows 11
- Windows Terminal
- Windows PowerShell 5.1 or PowerShell 7+

## Install

Clone this repository and run the installer:

```powershell
git clone https://github.com/hieudepzai14122007-ship-it/windows-terminal-transparency-toggle.git
cd windows-terminal-transparency-toggle
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Open a new PowerShell window after installation. The installer sets the initial opacity to 8%. To choose a different initial value:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DefaultOpacity 25
```

## Usage

Set an exact opacity percentage from 1 to 100:

```powershell
tt 8
```

Toggle between 8% opacity and solid:

```powershell
tt
```

Return to a completely solid background:

```powershell
tt 100
```

Windows Terminal usually reloads the appearance immediately. If it does not, open a new tab or window.

## Uninstall

From the cloned repository, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

Uninstalling removes the `tt` command but leaves the current opacity unchanged. Run `tt 100` before uninstalling if you want a solid background.

## Safety

The first time `tt` runs, it creates `settings.json.tt-backup` next to your Windows Terminal settings file. The tool only changes these shared profile defaults:

- `opacity`
- `useAcrylic` (kept disabled for clear, unblurred transparency)

## License

MIT
