# WindowsEventLogs
Functions for working with Windows Event Logs

## Get-UserNamesFromSecurityLog
This snippet takes the export of the Windows Security log and returns a list of user ids from within it.
### Exporting the Logs
1. Open Event Viewer in Windows, select the Security Log and choose "Save All Events As...." - save the file as a Comma Delimited CSV.
![Event Viewer](images/eventviewer.png)
2. Open the exported file in Notepad and add ",Description" to the end of the first line (PowerShell won't import the description field otherwise). Save the file.
![Notepad](images/notepad.png)

Now the PowerShell [Get-UserNamesFromSecurityLog](./Get-UserNamesFromSecurityLog.ps1) can be used on the resulting file.
