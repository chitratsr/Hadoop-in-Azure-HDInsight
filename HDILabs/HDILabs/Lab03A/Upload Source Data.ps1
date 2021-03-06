$clusterName = "clusterHive"
$storageAccountName = "hdstores"
$containerName = "hdfiles"

$thisfolder = Split-Path -parent $MyInvocation.MyCommand.Definition
$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $storageAccountName).Primary
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Remove output from previous execution
Get-AzureStorageBlob -Container $containerName -blob *data/*weather* -Context $blobContext | ForEach-Object {Remove-AzureStorageBlob -Blob $_.Name -Container $containerName -Context $blobContext}

# Upload source data
$localfile = "$thisfolder\heathrow.txt"
$destBlob = "data/weather/heathrow.txt"
Set-AzureStorageBlobContent -File $localFile -Container $containerName -Blob $destBlob -Context $blobContext -Force