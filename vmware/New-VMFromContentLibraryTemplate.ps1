<#
.Synopsis
   Deploy a new VM from a Content Library Template
.DESCRIPTION
    Deploy a new VM from a Content Library Template
    Apply a Customisation
    Set EFI Boot (if switch is selected)
    Power on and wait for customisation to finish
.EXAMPLE
   $VM= New-VMFromContentLibraryTemplate -VMName MyTestVM
.OUTPUTS
   The VM object of the created VM
#>
Function New-VMFromContentLibraryTemplate {   
    Param ( 
        [Parameter(Mandatory = $True)]
        [string]$VMName,
        #Default Values have been given here
        #either adjust for your environment or replace with mandatory parameters
        [string]$TemplateName = "WindowsServer2016", #Template to use for new VM
        [string]$ClusterName = "Cluster-Alpha", #Cluster to Deploy new VM to
        [string]$ResourcePoolName = "Resources", #Leave as "Resources" for default pool in cluster
        [string]$CustomizationSpec = "WinSrv2016-DomainJoin", #OS Customisation spec to use
        [string]$Datastore = "vsandatastore", #Datastore to deploy new VM to
        [switch]$EFI = $true #$true= EFI, $false=BIOS
    )
    

    
    #Get specified resource pool from Cluster
    $ResourcePool = Get-Cluster -Name $ClusterName | Get-ResourcePool -Name $ResourcePoolName
    
    #Deploy VM
    #Only the first template of that name is selected to prevent the function from trying to 
    #deploy multiple VMs with the same name.
    $VM =  Get-ContentLibraryItem -Name $TemplateName | select-object -first 1 | New-VM -ResourcePool $ResourcePool -Name $VMName -Datastore $Datastore 
    #Check VM Was Created
    If ($VM) {
           
        if ($EFI) {
            #Set EFI Boot (if template uses EFI rather than BIOS)
            #Source https://code.vmware.com/forums/2530/vsphere-powercli#538973
            $spec = new-object VMware.Vim.VirtualMachineConfigSpec
            $spec.Firmware = New-Object VMware.Vim.GuestOsDescriptor
            $spec.Firmware = "efi"
            $task = $vm.ExtensionData.ReconfigVM_Task($spec)
        }

         #Apply OS Customisation
         $VM | Set-VM -OSCustomizationSpec $customizationspec -confirm:$false

        #Power On VM
        Start-VM $VM -InformationAction SilentlyContinue
        #Wait For VMTools to start and the Hostname to be correct (i.e. domain has been joined)
        Write-Debug "Waiting for VM to start and customisations etc to complete"
        #Create a Counter so that we don't get stuck here waiting for lemon-soaked paper napkins
        #We timeout after ~1500 seconds (Counter > 500, 3 second pause) have elapsed.
        $Counter = 0
        do {
            $Counter++
            $ToolsStatus = (Get-VM $vm | Get-View).Guest.ToolsStatus
            #Wait 3 seconds and try again
            Start-Sleep -Seconds 3
            $Hostname = (Get-VMGuest -VM $VM).Hostname
        } until (( ( $ToolsStatus -eq ‘toolsOk’ ) -and ("$Hostname".StartsWith( $VMName) )) -or ($Counter -gt 500 ) )
    }
    #return the VM (if created) here
    $VM
}
    