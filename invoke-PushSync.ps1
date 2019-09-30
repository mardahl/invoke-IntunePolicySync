#Requires -RunAsAdministrator
<#
  A simpler approach to initiating an MDM sync, as explained by 
  @mniehaus in his blog post https://oofhours.com/2019/09/28/forcing-an-mdm-sync-from-a-windows-10-client/
  This method should be run as SYSTEM or an administrative account.
#>

Start-ScheduledTask -TaskName "PushLaunch"
