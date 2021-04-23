#PowerShell- How many days till the end of extended support for Windows Server 2012 and 2012R2
#https://docs.microsoft.com/en-us/lifecycle/products/windows-server-2012-r2

# Set a date variable for the end of Windows Server 2012 Support
$EOLDate=get-date -Year 2023 -Month 10 -Day 10 -Hour 0 -Minute 0 -Second 1
# Set a date variable for today
$Now= get-date -Hour 0 -Minute 0 -Second 0
# Display a message with the difference between today's date and the End of Support date.
"There are "+ ($EOLDate - $Now).Days + " days left till the end of extended support for Windows Server 2012"