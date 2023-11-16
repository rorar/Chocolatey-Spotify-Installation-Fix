# Check if the script is run as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run the script as an administrator. Exiting..."
    exit
}

# Prompt user to uninstall Spotify Windows Store version for all users
do {
    $timeoutSeconds = 8
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $continue = $true

    while ($stopwatch.Elapsed.TotalSeconds -lt $timeoutSeconds -and $continue) {
        # Calculate remaining seconds and round
        $remainingSeconds = [math]::Round($timeoutSeconds - $stopwatch.Elapsed.TotalSeconds, 0)

        # Clear the console
        [System.Console]::Clear()

        # Display the countdown message while waiting for user input
        Write-Host @"
Auto Do you want to uninstall the Spotify Windows Store version for all users? 
- [Y] Yes (Auto Continue in $remainingSeconds seconds) 
- [N] No (abort) 
- [C] Continue without uninstalling
Please press a key...
"@ -NoNewline

        if ($Host.UI.RawUI.KeyAvailable) {
            $keyPressed = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp, IncludeKeyDown")

            switch ($keyPressed.Character) {
                'Y' {
                    # User selected 'Y' for Yes
                    $continue = $false
                    Write-Host "`nUninstalling Spotify Windows Store version for all users..."
                    # Uninstall Spotify Windows Store version for all users
                    Get-AppxPackage -AllUsers *Spotify* | Remove-AppxPackage
                    Write-Host "Uninstallation completed."
                    break
                }
                'N' {
                    # User selected 'N' for No
                    $continue = $false
                    Write-Host "`nNo uninstallation performed. Exiting..."
                    Start-Sleep -Seconds 5
                    exit
                }
                'C' {
                    # User selected 'C' for Continue
                    $continue = $false
                    Write-Host "`nContinuing with version selection and installation..."
                    # Continue to version selection and installation
                    break
                }
            }
        }
        Start-Sleep -Seconds 1
    }

    if ($continue) {
        Write-Host "`nNo input received within $timeoutSeconds seconds. Proceeding with default action."

        # Default action - Uninstall Spotify Windows Store version for all users
        Write-Host "Uninstalling Spotify Windows Store version for all users..."
        Get-AppxPackage -AllUsers *Spotify* | Remove-AppxPackage
        Write-Host "Uninstallation completed."
    }

    # Get subfolders in %Temp%\chocolatey\spotify\ and extract version numbers
    $chocolateyTempPath = [System.IO.Path]::Combine($env:Temp, 'chocolatey', 'spotify')
    $subfolders = Get-ChildItem -Path $chocolateyTempPath -Directory | Sort-Object { [Version]($_.Name) } -Descending

    if ($subfolders.Count -gt 0) {
        # Display selectable list of version numbers
        do {
            $timeoutSecondsVersionSelection = 10
            $stopwatchVersionSelection = [System.Diagnostics.Stopwatch]::StartNew()
            $continueVersionSelection = $true

            while ($stopwatchVersionSelection.Elapsed.TotalSeconds -lt $timeoutSecondsVersionSelection -and $continueVersionSelection) {
                # Calculate remaining seconds and round
                $remainingSecondsVersionSelection = [math]::Round($timeoutSecondsVersionSelection - $stopwatchVersionSelection.Elapsed.TotalSeconds, 0)

                # Clear the console
                [System.Console]::Clear()

                # Display the countdown message while waiting for user input
                Write-Host @"
Select a version to install (Auto Continue in $remainingSecondsVersionSelection seconds):
"@ -NoNewline

                # Display version numbers dynamically
                for ($i = 0; $i -lt $subfolders.Count; $i++) {
                    if ($i -eq 0) {
                        Write-Host ""
                    }
                    Write-Host "$($i + 1). $($subfolders[$i].Name)"
                }

                Write-Host "Please select a Version..."

                if ($Host.UI.RawUI.KeyAvailable) {
                    $keyPressed = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyUp, IncludeKeyDown")

                    # Check if the pressed key corresponds to a folder number
                    $nFolder = [int]::Parse($keyPressed.Character)
                    if ($nFolder -ge 1 -and $nFolder -le $subfolders.Count) {
                        $continueVersionSelection = $false

                        # User selected a version number
                        $selectedVersion = $subfolders[$nFolder - 1].Name
                        Write-Host "`nSelected version: $selectedVersion"
                    }
                }
                Start-Sleep -Seconds 1
            }

            if ($continueVersionSelection) {
                Write-Host "`nNo input received within $timeoutSecondsVersionSelection seconds. Auto-selecting the first version..."
                $selectedVersion = $subfolders[0].Name
                Write-Host "Selected version: $selectedVersion"
            }

            # Check if the setup file exists in the selected version folder
            $setupFilePath = [System.IO.Path]::Combine($chocolateyTempPath, $selectedVersion, 'SpotifyFullSetup.exe')

            if (Test-Path $setupFilePath) {
                # Adjusted start time to 20 seconds from now
                $scheduledTime = (Get-Date).AddSeconds(20).ToString("HH:mm")

                # Remove the scheduled task if it already exists
                Unregister-ScheduledTask -TaskName "InstallSpotifyTask" -Confirm:$false

                # Schedule the task using Set-ScheduledTask
                $taskAction = New-ScheduledTaskAction -Execute "$setupFilePath"
                $taskTrigger = New-ScheduledTaskTrigger -Once -At $scheduledTime
                $taskSettings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
                Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName "InstallSpotifyTask" -Settings $taskSettings -Force

                Write-Host "Task scheduled to run Spotify installer at $scheduledTime."

                # Run the task immediately
                Start-ScheduledTask -TaskName "InstallSpotifyTask"

                # Wait for the task to complete (adjust the timeout as needed)
                Start-Sleep -Seconds 20

                # Delete the scheduled task
                Unregister-ScheduledTask -TaskName "InstallSpotifyTask" -Confirm:$false

                Write-Host "Scheduled task removed."
            } else {
                Write-Host "Setup file not found for version $selectedVersion. Exiting..."
            }

        } while ($subfolders.Count -eq 0)

    } else {
        # Ask the user if they want to run "choco install spotify" and restart the script
        $installChoco = Read-Host "No Spotify versions found. Would you like to install Spotify using Chocolatey? (Y/N)"
        if ($installChoco -eq 'Y' -or $installChoco -eq 'Yes') {
            Write-Host "Running 'choco install spotify'..."
            choco install spotify -y
            Start-Sleep -Seconds 5
            exit
        } else {
            Write-Host "Thanks for using the script. Exiting in 5 seconds..."
            Start-Sleep -Seconds 5
            exit
        }
    }
} while ($true)  # Add a condition to exit the loop if needed
