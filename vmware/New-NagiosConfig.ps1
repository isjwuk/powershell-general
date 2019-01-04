<#
Script name:    new-nagiosconfig.ps1
Created on:     04/01/2019
Author:         Chris Bradshaw @aldershotchris
Description:    The purpose of the script is to take a VM and produce a Nagios config file.
                Resulting text can be added to the config on a Nagios monitoring server
Dependencies:   Existing connection to vCenter (Connect-VIServer)
                VMTools running on target VM
                NRPE/NSClient++ will be needed on VM Guest OS for output to be useful

===Tested Against Environment====
vSphere Version: 6.5
PowerCLI Version: PowerCLI 11.0.0
PowerShell Version: 5.1
OS Version: Windows 10
Nagios Version: 4.2.4
#>


Function New-NagiosConfig {
    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline)] [PSObject]$VM
        )
    Process {
        #Try resolving VM object
        #Allows a VM Name or VM object to be passed to this function
        try {
            $MyVM=Get-VM($VM)
            If (! $MyVM)
            {
                Write-Error -Message "Failed to resolve VM"
                return
            }
        } 
        catch {
            Write-Error -Message "Failed to identify VM"
            return
        }
        #Is VM Tools installed? 
        #We can't proceed without it as we need to resolve the IP address
        $VMToolsStatus=(Get-VM $MyVM | Get-View).Guest.ToolsStatus
        if ( $VMToolsStatus -ne 'toolsOk' -and $VMToolsStatus -ne 'toolsOld')
        {
            Write-Error -Message "VMTools Not Running"
            return
        }
        #Get IP Addresses. 
        #Which one should we use? 
        #This method decides by getting the hostname and doing an NSlookup
        #If that result matches one of the Guest IPs we proceed with that.
        $DNSIP=(Resolve-DnsName -Name $MyVM.Guest.HostName).IPAddress
        If ($MyVM.Guest.IPAddress -notcontains $DNSIP)
        {
            Write-Error -Message "Cannot find IP Address of VM"
            return
        }
        #Get the GuestOS to determine which Nagios template to use
        #Using vanilla Nagios out of the box we have 
        #"windows-server" and "linux-server" to play with here.
        If ($MyVM.Guest -like "*Windows*")
        {
            $Template="windows-server"
        }else{
            $Template="linux-server"
        }
        #Output block defining host in Nagios.
        "#Auto-Generated Nagios Config for "+$MyVM.Name
        "define host{"
        "   use    "    +$Template +            "   ; Inherit default values from a template"
        "   host_name  "+$MyVM.Name+            "   ; The name we're giving to this host"
        "   alias      "+$MyVM.Guest.HostName+  "   ; A longer name associated with the host"
        "   address    "+$DNSIP+                "   ; Address of the host"
        "}"
        " "
        #Output OS-Specific Service definitions
        if ($Template -eq "windows-server")
        {
            #Output Block for Generic Windows Server 
            #Assume Nagios NSClient++ is installed in GuestOS
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     Memory Usage"
            "    check_command           check_nt!MEMUSE!-w 80 -c 90"
            "    }"
            " "
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     CPU Load"
            "    check_command           check_nt!CPULOAD!-l 5,80,90"
            "    }"
            " "
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     C:\ Drive Space"
            "    check_command           check_nt!USEDDISKSPACE!-l c -w 85 -c 90"
            "    }"
            " "
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     Uptime"
            "    check_command           check_nt!UPTIME"
            "    }"
            " "
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     NSClient++ Version"
            "    check_command           check_nt!CLIENTVERSION"
            "    }"
            " "
        }
        if ($Template -eq "linux-server")
        {
            #Output Block for Generic Linux Server 
            #Assume NRPE is installed in Guest OS
            "define service{"
            "    use                     generic-service"
            "    host_name               "+$MyVM.Name
            "    service_description     SSH"
            "    check_command           check_ssh"
            "    service_groups          report-services"
            "    }"
            " "
            "define service{"
                "    use                    generic-service"
                "    host_name              "+$MyVM.Name
                "    service_description    Current Users"
                "    check_command          check_nrpe!check_users"
            "}"
            " "
            #Modify Disk Assignments as appropriate
            "define service{"
                "   use                     generic-service"
                "   host_name               "+$MyVM.Name
                "   service_description     / Free Space"
                "   check_command           check_nrpe!check_disk1"
            "}"
            " "
            "define service{"
                "   use                     generic-service"
                "   host_name               "+$MyVM.Name
                "   service_description     /home Free Space"
                "   check_command           check_nrpe!check_disk2"
            "}"
            " "
            "define service{"
                "   use                     generic-service"
                "   host_name               "+$MyVM.Name
                "   service_description     CPU Load"
                "   check_command           check_nrpe!check_load"
            "}"
            " "
        }
    }
    
}

