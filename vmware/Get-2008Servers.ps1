#
# Search a vSphere environment for powered on VMs running Server 2008 as a Guest OS
# https://isjw.uk/find-windows-2008-vms/
#

Get-VM |
 Where {$_.PowerState -eq "PoweredOn" -and
 ($_.Guest -like "*Server 2008*")} |
 Get-VMGuest |
 Select VMName, OSFullName
