<#
Script name:    lapsafe-api-examples.ps1
Created on:     05/02/2019
Author:         Chris Bradshaw @aldershotchris
Description:    Powershell examples of reading from the LapSafe Diplomat API
Dependencies:   API key from LapSafe.com
                
===Tested Against Environment====
PowerShell Version: 5.1
OS Version: Windows 10
#>

#Complete these two fields using your own API details from LapSafe
$resource="https://xxxxx" #URL
$apikey="xxxxx"           #API Key

#Retrieve the JSON for the dashboard
$JSON=Invoke-RestMethod -Method Get -Uri $resource -Header @{ "apikey" = $apiKey }

#We can get all sorts of information by drilling down into this object
#Example 1: Show a table of the Installations, their capacity, and current number of devices available
$JSON.data.installs | Select-Object installName, totalBays, totalAvailable

#Example 2: Extend this to show the Total capacity and devices available across all installations
$Data=$JSON.data.installs | Select-Object installName, totalBays, totalAvailable
$TotalAvailable=    ($Data.totalAvailable | Measure-Object -Sum).sum
$TotalBays=         ($Data.totalBays | Measure-Object -Sum).sum
