#Create a table of the last build dates of one or more computers
#Be aware that for a large range of computers this may take some time
# especially if some are inaccessible.
# (Build date= Last Windows Install Date)
#Returns a null value for BuildDate if the computer is not found

#Example Usage
# ("WS40200","WS46000") | Get-BuildDate
# Computer BuildDate           DaysSinceLastBuild
# -------- ---------           ------------------
# WS40200
# WS46000  17/07/2018 20:20:39 55
#
# Get-BuildDate ("WS40200","WS46000")
# $Computers=((12300..12399) | ForEach-Object{ "WS$_"}) | Get-BuildDate
# See https://isjw.uk/remote-win-install-date-powershell/ for more details

function Get-BuildDate {
    param(
        [parameter(Mandatory=$true,Position=0,ValueFromPipeline)] [string[]]$ComputerNames
         )
    Process {
        ForEach($Computer in $ComputerNames)
        {
            #Set Default Values in case a computer cannot be accessed
            $BuildDate=$null
            $DaysAgo=$null
            #Put an error catcher here to smarten up output if computer is not found
            Try { 
                #Retrieve the BuildDate via WMI
                $BuildDate=Get-Date -Date (Get-WMIObject win32_OperatingSystem).ConvertToDateTime((Get-WmiObject win32_OperatingSystem -computername $Computer -ErrorAction:SilentlyContinue).InstallDate ) -ErrorAction:SilentlyContinue 
                #Calculate days since BuildDate
                $DaysAgo=( (Get-Date) - $BuildDate ).Days
            } Catch {    }
            #Output the result
            $Computer| select-Object @{Name="Computer";Expression={$_}}, @{Name="BuildDate";Expression={$BuildDate.ToString()}}, @{Name="DaysSinceLastBuild";Expression={$DaysAgo}}
        } #End ForEach
    } #End Process
} #End Function


