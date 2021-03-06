$clusterName = "clusterHive"
$storageAccountName = "hdstores"
$containerName = "hdfiles"

$thisfolder = Split-Path -parent $MyInvocation.MyCommand.Definition
$storageAccountKey = (Get-AzureStorageKey -StorageAccountName $storageAccountName).Primary
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$destfolder = "data"

# Remove output from previous execution
If (Test-Path "$thisfolder\$destfolder") {
  Remove-Item "$thisfolder\$destfolder" -Recurse -Force
}

Get-AzureStorageBlob -Container $containerName -blob *data/*weather* -Context $blobContext | ForEach-Object {Remove-AzureStorageBlob -Blob $_.Name -Container $containerName -Context $blobContext}

# Upload source data
$file = "scrubbedweather.txt"
$blobName = "$destfolder/scrubbedweather/$file"
$filename = "$thisfolder\$file"
Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force

# Upload Python file
$file = "convert_temp.py"
$blobName = "$destfolder/$file"
$filename = "$thisfolder\$file"
Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force

# Upload Pig Latin script
$file = "convert_weather.pig"
$blobName = "$destfolder/$file"
$filename = "$thisfolder\$file"
Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force

# Run the Pig job
$jobDef = New-AzureHDInsightPigJobDefinition -File "wasb:///$destfolder/$file"
$pigJob = Start-AzureHDInsightJob -Cluster $clusterName -JobDefinition $jobDef
Write-Host "Pig job submitted..."
Wait-AzureHDInsightJob -Job $pigJob -WaitTimeoutInSeconds 3600
Get-AzureHDInsightJobOutput -Cluster $clusterName -JobId $pigJob.JobId -StandardError

# Get the job output
$outputFolder = "convertedweather"
$outputFile = "part-m-00000"
$remoteblob = "$destfolder/$outputFolder/$outputFile"
write-host "Downloading $remoteBlob..."
Get-AzureStorageBlobContent -Container $containerName -Blob $remoteblob -Context $blobContext -Destination $thisfolder
cat $thisfolder\$destfolder\$outputFolder\$outputFile