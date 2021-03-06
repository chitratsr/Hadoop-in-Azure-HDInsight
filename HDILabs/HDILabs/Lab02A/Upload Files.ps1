$storageAccountName = "gdwanghstorage"
$containerName = "hdfiles"

$thisfolder = Split-Path -parent $MyInvocation.MyCommand.Definition
$localFolder = "$thisfolder\iislogs_gz"
$destfolder = "data/logs"


# Upload data files
$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $storageAccountName).Primary
$destContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$files = Get-ChildItem $localFolder
foreach($file in $files){
  $fileName = "$localFolder\$file"
  $blobName = "$destfolder/$file"
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $destContext -Force
}
write-host "All files in $localFolder uploaded to $containerName!"

