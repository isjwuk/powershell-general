    #Create a new DFS Folder with two targets and assign ABE permissions.
    New-DFSNFolder -Path "$NewDFSFolderPath" -TargetPath "$PrimaryTarget" -ReferralPriorityClass GlobalHigh
    New-DFSNFolderTarget -Path "$NewDFSFolderPath" -TargetPath "$SecondaryTarget" -ReferralPriorityClass GlobalLow
    dfsutil property acl grant $NewDFSFolderPath $ReadGroup`:RX $WriteGroup`:RX Protect Replace