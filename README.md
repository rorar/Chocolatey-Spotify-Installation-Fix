# Chocolatey-Spotify-Installation-Fix
This Scripts allows you to fix the issue if you can't install Spotify because of the hanging scheduled task. 

## Error desciption
If Spotify is installed over Chocolatey, it might hang at this point:
```
SUCCESS: The scheduled task "spotify" has successfully been created.
SUCCESS: Attempted to run the scheduled task "spotify".
SUCCESS: The scheduled task "spotify" was successfully deleted.
```
The Chocolatey Installer doesn't check for these:
➡️ Uninstallation of Spotify Windows Store App, as this could be the culprit.
➡️ Missing Flags for `New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries`

## What the script does
- Uninstalls Spotify Windows Store App for all users (can be skipped with pressing "C")
- Checks for Spotify Installers in the subfolders of %Temp%\chocolatey\spotify\
- If not present, it offers you to run `choco install spotify`for you
- Otherwise you can select a version or let the installer autocontine
- over the task scheduler the spotify setup is fired

## How to run the script
1. Either set the Set-ExecutionPolicy to unrestricted, just open Powershell as admin and enter `Set-ExecutionPolicy unrestricted`
2. Or temporarily whitelist a script using `powershell.exe -noprofile -executionpolicy bypass -file .\Path\To\Script\Chocolatey-Spotify-Installation-Fix.ps1
