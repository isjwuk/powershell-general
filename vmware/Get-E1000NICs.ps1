<#
Script name:    Get-E1000NICs.ps1
Created on:     09/01/2019
Author:         Chris Bradshaw @aldershotchris
Description:    Find all the powered on VMs in the environment using an E1000 NIC
Dependencies:   Existing connection to vCenter (Connect-VIServer)
                
===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 11.0.0
PowerShell Version: 5.1
OS Version: Windows 10
#>

Function Get-E1000NICs {
    Get-VM | 
    Where-Object {$_.PowerState -eq "PoweredOn" -and ($_ | Get-NetworkAdapter).Type -like "e1000*"}
}