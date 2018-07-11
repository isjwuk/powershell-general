#Snippet of PowerShell which anonymises names in GraphPad Prism Activation Reports
#
#GraphPad Prism Group Subscriptions include activation reports
#These contain potentially useful information for future usage modelling
#But also include personally identifiable information (PII)
#User's names are included which we don't want to keep but we may be interested
#in knowing how many devices were activated by a single user (for example).
#This snippet anonymises the users names in the report.
#
#Download the Activation report from www.graphpad.com 
#and save the resulting Excel Spreadsheet as a CSV file, referenced below.
#
#Thanks-
# https://tfl09.blogspot.com/2017/08/creating-sha1-hash-using-powershell.html for the SHA1 hash method
# https://d-fens.ch/2013/11/16/nobrainer-convert-byte-array-to-hex-string/ for the Hex encoding snippet
# https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/05/generate-random-letters-with-powershell/ for Random Word generation

#Set the path of the CSV File to process here. The results are saved back to this file.
$CSV_File= "activation_report_2017.csv"


# Generate a random word so that a user's name can't just be rehashed and found in the list
$BIG_WORD=-join ((65..90) + (97..122) | Get-Random -Count 64 | % {[char]$_})
#.NET reference to SHA1 Crypto
$sha1 = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider
#Import the CSV File and select the required fields, hashing the name along the way and then converting to a hex encoded string
$Output=  Import-Csv $CSV_File |
 Select-Object "Date",
	@{name="Anon-Name";Expression={[System.BitConverter]::ToString($sha1.ComputeHash($enc.GetBytes($_.Name+$BIG_WORD)))}},
	"Computer",
	"Version",
	"Platform", 
	"Active", 
	"Date Deactivated"
#Save the Output as CSV
$Output | Export-Csv -Path $CSV_File -NoTypeInformation
