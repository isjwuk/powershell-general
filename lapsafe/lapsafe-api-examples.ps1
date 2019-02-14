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

#Example 2: Show the Total capacity and devices available across all installations
$JSON.data | Select-Object totalAvailable, totalBays

#Example 3: Show the number of devices currently on charge in "Installation: A"
($JSON.data.installs | Where-Object {$_.installName -eq "Installation: A"}).totalOnCharge

#Example 4: Show the name and number of devices available of the installation with the most available devices.
$JSON.data.installs | Select-Object installName, totalAvailable | Sort-Object -Property totalAvailable -Descending |Select-Object -First 1