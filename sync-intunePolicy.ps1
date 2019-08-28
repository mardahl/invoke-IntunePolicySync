#requires -version 5.0
<#
.SYNOPSIS
Starts Intune Policy Sync
.REQUIREMENTS
This script myst be run as the user
Giving AdminConset by running these two lines manually first time as a global admin (tenant wide fix)
    Import-Module -Name Microsoft.Graph.Intune
    Connect-MSGraph -adminconsent -ForceNonInteractive # change the switch to -AdminConsent
.EXAMPLE
Just run the script sync-intunePolicy.ps1 without any parameters, as the user enrolling the device.
.COPYRIGHT
MIT License, feel free to distribute and use as you like, please leave author information.
.AUTHOR
Michael Mardahl - @michael_mardahl on twitter - BLOG: https://www.iphase.dk
.DISCLAIMER
This script is provided AS-IS, with no warranty - Use at own risk!
#>

#Starting a log, just in case...
Start-Transcript "$($env:temp)\script_sync-intunePolicy_log.txt" -Force

Write-Output "Importing Powershell modules for Intune"
Import-Module -Name Microsoft.Graph.Intune

Write-Output "Connecting to Graph"
Connect-MSGraph -adminconsent -ForceNonInteractive # change the switch to -AdminConsent when first running this command in your tenant to disable future prompts

Write-Output "Looking up device..."
$IntuneDevice = get-intunemanageddevice | Where-Object deviceName -Like $env:COMPUTERNAME
if ($IntuneDevice -ne $null){
    Write-Output "Sending sync signal to Intune"
    $IntuneDevice | Invoke-IntuneManagedDeviceSyncDevice
} else {
    Write-Output "Device not found in intune"
}

Write-Output "Done."

Stop-Transcript