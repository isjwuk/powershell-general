function GBStringtoGB
#Using the Dell FFS PowerShell, Quota Rule properties coming back as "500 GB" 
#rather than 500 GB (i.e. string rather than number of gigabytes).
#Translate "500 GB" into a number of Gigabytes and handle other xB unit possibilities too.
#Assumes an input string formatted Number-Space-Unit
{
    param( [string]$StringInput )
    $Value=[int]$StringInput.SPlit(" ")[0]
    switch ($StringInput.SPlit(" ")[1]) 
        { 
            "KB" {$Output=$Value*1KB}
            "MB" {$Output=$Value*1MB} 
            "GB" {$Output=$Value*1GB} 
            "TB" {$Output=$Value*1TB} 
            "PB" {$Output=$Value*1PB} 
            default {$Output=$Value}
        }
        $Output /1GB
}

#Example Usage
GBStringtoGB("500 TB")
