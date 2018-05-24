	<#
	.Synopsis
	    List all the folders in a datastore which contain VMDK files
	.DESCRIPTION
	    List all the folders in a datastore which contain VMDK files.
	.EXAMPLE
	   $FolderList= Get-VmdkFolders -Datastore MyDatastore
	.OUTPUTS
	   The List of Folders paths within the datastore containing VMDKs
	#>
	Function Get-VmdkFolders {   
   Param ( 
      [Parameter(Mandatory = $True)]
      [string]$Datastore
    )
    #Create a name for a temporary PS Drive
	  #Use a GUID to create a unique name
	  $TempDriveName=[guid]::NewGuid().ToString()
	  #Map the Datastore to a PS Drive 
	  New-PSDrive -Location (Get-Datastore -Name $Datastore) -Name $TempDriveName -PSProvider VimDatastore -Root '\'  -Scope Script | Out-Null
	  #Add the Drive Notation to the drive Name
	  $TempDriveName=$TempDriveName+":\"
	  #Enumerate all the vmdk files on the datastore
	  $VMDKs= get-childitem -Path $TempDriveName -Recurse -Filter "*.vmdk"
	  #Get a list of all the unique folder paths containing VMDKs
	  $FolderPaths= $VMDKs | select FolderPath | Sort-Object FolderPath | Get-Unique -AsString
	  #Remove the Drive Notation from the drive Name
	  $TempDriveName=$TempDriveName -replace "\:\\",""
	  #Tidy up the datastore mapping
	  Remove-PSDrive -Name $TempDriveName
	  #Remove the datastore from the text and return a list of Folder Paths
	  $FolderPaths.FolderPath -replace "\[$Datastore\] ",""
}
