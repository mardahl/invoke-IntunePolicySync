#requires -version 5.0
<#
.SYNOPSIS
Starts Intune Policy Sync
.REQUIREMENTS
This script must be run as the user
Giving AdminConset by running these three lines manually first time as a global admin from an admin PowerShell prompt (tenant wide fix)
    Install-Module -Name Microsoft.Graph.Intune
    Import-Module -Name Microsoft.Graph.Intune
    Connect-MSGraph -AdminConsent
.EXAMPLE
Just run the script Invoke-IntunePolicySync.ps1 without any parameters, as the user enroling the device.
.COPYRIGHT
MIT License, feel free to distribute and use as you like, please leave author information.
.AUTHOR
Michael Mardahl - @michael_mardahl on twitter - BLOG: https://www.iphase.dk
.DISCLAIMER
This script is provided AS-IS, with no warranty - Use at own risk!
#>

#Starting a log, just in case...
Start-Transcript "$($env:temp)\script_Invoke-IntunePolicySync.ps1_log.txt" -Force

Write-Output "Importing Powershell modules for Intune"
try { 
    Import-Module -Name Microsoft.Graph.Intune -ErrorAction Stop
} 
catch {
    Write-Output "Microsoft.Graph.Intune module not found in common module path, installing in the current user scope..."
    Install-Module -Name Microsoft.Graph.Intune -Scope CurrentUser -Force
    Import-Module Microsoft.Graph.Intune -Force
}

Write-Output "Connecting to Graph"
try {
    Connect-MSGraph -ForceNonInteractive -ErrorAction Stop
    # change the switch to -AdminConsent when first running this command in your tenant to disable future prompts
} catch {
    Write-Error "Failed to connect to MSGraph! Did you remember to give Admin Consent?"
    Exit 1
}

Write-Output "Looking up device..."
try {
    $deviceObj = get-intunemanageddevice | Where-Object deviceName -Like $env:COMPUTERNAME
} catch {
    Write-Error "Failed to fetch device! Permissions or Admin Consent issue perhaps?"
    Exit 1
}

if ($deviceObj -ne $null){
    Write-Output "Sending sync signal to Intune Device"
    $deviceObj | Invoke-IntuneManagedDeviceSyncDevice -ErrorAction Stop
} else {
    Write-Output "Device not found in intune (You might want to verify this manually in the Intune Portal)"
}

Write-Output "Done."

Stop-Transcript
