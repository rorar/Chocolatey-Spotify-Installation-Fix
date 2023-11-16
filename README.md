# Chocolatey-Spotify-Installation-Fix
This Scripts allows you to fix the issue if you can't install Spotify because of the hanging scheduled task. 
Might not work on Windows 7

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
Run the script with admin privileges. To do so, type in "Powershell" in the searchbar and select "Run as adminstrator".
- Option 1: If not done yet, you Set-ExecutionPolicy to unrestricted, just open Powershell as admin and enter `Set-ExecutionPolicy unrestricted` 
- Option 2: Download the script in the dowmload folder and temporarily whitelist the script using `powershell.exe -noprofile -executionpolicy bypass -file $HOME\Downloads\\Chocolatey-Spotify-Installation-Fix.ps1`

### Regarding Windows 7
There might be a fix here that's not implemented:
https://superuser.com/a/1778056
