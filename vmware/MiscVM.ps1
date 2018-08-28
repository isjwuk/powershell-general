#Miscellaneous VM related snippets
#Needs PowerCLI and connection to vCenter using Connect-VIServer

#List all VMs in a cluster with thick provisioned disks.
$ClusterName="Cluster-Alpha"
Get-Cluster "$ClusterName" |
 Get-VM |
 Select-Object Name, @{Name="StorageFormat"; Expression={( get-harddisk -VM $_ ).StorageFormat}} | Where-Object {$_.StorageFormat -Contains "Thick"}

#Get Number of Powered On VMs Per Cluster
Get-Cluster |
 Select-Object Name, @{Name="Powered On VMs";Expression={($_ | Get-VM  | Where-Object {$_.PowerState -eq "PoweredOn"} | Measure-Object).Count}}

#Get Number of VMs in each datastore
Get-Datastore | 
 Select-Object Name, @{Name="VM Count"; Expression={ (Get-Datastore $_ | Get-VM |Measure-Object).Count}} |
 Sort-Object -Descending -Property "VM Count", "Name"

#Move all Powered Off VMs from $Host1 to $Host2
$Host1="ESX1"
$Host2="ESX2"
Get-vmhost -Name $Host1 |
 get-vm | Where-Object {$_.PowerState -eq "PoweredOff"} |
 Move-vm -Destination (Get-VMHost -Name $Host2)

#Get total disk space usage in GB of all powered on VMs.
# See https://isjw.uk/using-powercli-to-measure-vm-disk-space-usage/
[math]::Round(((get-vm | Where-object{$_.PowerState -eq "PoweredOn" }).UsedSpaceGB | measure-Object -Sum).Sum)

#List all running VM tasks on vCenter
Get-Task |
  Where-Object {$_.State -eq "running" -and $_.objectid -like "VirtualMachine*"} | 
  Select-Object  @{Name="VM Name";Expression={(Get-VM -ID $_.ObjectID).Name}}, Name, StartTime, PercentComplete

#List all hosts along with the DELL Service Tag.
Get-View -ViewType HostSystem |
  Select-Object Name,@{N="Tag";E={$_.Summary.Hardware.OtherIdentifyingInfo[1].IdentifierValue}}
