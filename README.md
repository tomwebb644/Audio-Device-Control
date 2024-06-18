# Audio-Device-Control
Toggle between pre-defined audio devices by run script (built as a keyboard macro)

# Setup
Open Powershell in admin and run:
Set-Executionpolicy remotesigned 
Install-Module -Name AudioDeviceCmdlets 
Install-Module -Name ps2exe 

#Generate Executable
Open Powershell and run:
Invoke-ps2exe .\Audio_Device_Switcher.ps1 .\Audio_Device_Switcher.exe -noconsole -nooutput
