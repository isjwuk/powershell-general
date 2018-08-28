#Miscellaneous AD related Powershell snippets

#Change Account Expiration on Sequentially Numbered AD Accounts
#This will get v1001 through v1048 (v1001, v1002, v1003... v1048) and set the expiry date to September 20th 2019 00:00.
(01..48) | ForEach-Object{ "v10$_"} |Get-ADUser | Set-ADAccountExpiration -DateTime "2019-09-20"