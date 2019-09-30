<#
  Experimental script! Just for inspiration (playing around)
  This is supposed to be run in a user context, but still requires that the user can elevate a process.
#>

# Fetch the PushLaunch command from the task scheduler
$Command = Get-ScheduledTask -TaskName "PushLaunch" | Select-Object -ExpandProperty Actions

# Starting the process
Start-Process -FilePath "$env:windir\system32\deviceenroller.exe" `
 -Verb Runas `
 -ArgumentList "$($Command.Arguments)"
