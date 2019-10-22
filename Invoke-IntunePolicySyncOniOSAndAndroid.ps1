#requires -version 5.0
<#
.SYNOPSIS
Starts Intune Policy Sync on all iOS and Android devices remotely
.REQUIREMENTS
This script must be run from a Windows 10 Device
You will need to grant AdminConset by running these three lines manually first time as a global admin from 
an admin PowerShell prompt (tenant wide fix)
    Install-Module -Name Microsoft.Graph.Intune
    Import-Module -Name Microsoft.Graph.Intune
    Connect-MSGraph -AdminConsent
.EXAMPLE
Just run the script Invoke-IntunePolicySyncOniOSAndAndroid.ps1 without any parameters, preferably as an Intune Admin.
.COPYRIGHT
MIT License, feel free to distribute and use as you like, please leave author information.
.AUTHOR
Michael Mardahl - @michael_mardahl on twitter - BLOG: https://www.iphase.dk
.VERSION
1910.1 #SCUGDK edition
.DISCLAIMER
This script is provided AS-IS, with no warranty - Use at own risk!
#>

#Starting a log, just in case...
Start-Transcript "$($env:TEMP)\script_Invoke-IntunePolicySyncOniOSAndAndroid.ps1_log.txt" -Force

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
    Connect-MSGraph -ForceNonInteractive -ErrorAction Stop -Quiet
    # change the switch to -AdminConsent when first running this command in your tenant to disable future prompts (see requirements note)
} catch {
    Write-Error "Failed to connect to MSGraph! Did you remember to give Admin Consent?"
    Exit 1
}

Write-Output "Getting iOS and Adroid device list"
try {
    $deviceObjList = @()
    $deviceObjList += get-intunemanageddevice | Where-Object operatingSystem -eq "Android"  | Get-MSGraphAllPages
    $deviceObjList += get-intunemanageddevice | Where-Object operatingSystem -eq "iOS"  | Get-MSGraphAllPages
} catch {
    Write-Error "Failed to fetch devices! Permissions or Admin Consent issue perhaps?"
    Exit 1
}

if (($deviceObjList).count -gt 0){
    Write-Output "Sending sync signal to all iOS and Android devices"
    foreach ($deviceObj in $deviceObjList) {
        try {
            "id: {0}    OS: {1,-8}    Name: {2,-50}    Owner: {3}" -f $deviceObj.id,$deviceObj.operatingSystem,$deviceObj.deviceName,$deviceObj.emailAddress
            $deviceObj | Invoke-IntuneManagedDeviceSyncDevice -ErrorAction Stop
        } catch {
            Write-Error "Failed to send signal to $($deviceObj.id)"
        }
    }
} else {
    Write-Output "No iOS or Android devices found in intune (You might want to verify this manually in the Intune Portal)"
}

Write-Output "Done."

Stop-Transcript
