#Upgrade VM Hardware on all VMs tagged "UpgradeMe"
#Code from London VMUG Presentation January 2017
$AllMyVMs = Get-VM
ForEach ($VM in $AllMyVMs) {
	$Tags= $VM | Get-TagAssigment | Select Tag
	If ($Tags.Tag.Name -Contains “UpgradeMe“){
		Stop-VMGuest –VM $VM
	   	do {
	 		Start-Sleep -s 5
			$VM = Get-VM $VM
   		}until($VM.PowerState -eq "PoweredOff")
		New-Snapshot -VM $VM -Name "HW Upgrade“
		Set-VM -VM $VM -Version v13
		Start-VM $VM 
		Wait-Tools –VM $VM
	}
}
