@echo off

::
:: Small script to have the policies on a new computer hammered on continuously until reboot.
::

echo "Waiting to sync intune and update group policy..."
timeout 240
start powershell.exe -nologo -windowstyle hidden -file "%~dp0\syncIntune.ps1"
timeout 120
gpupdate /force
start "" /min "%~dpnx0"
exit
