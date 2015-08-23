$storageAccountName = "gdwanghhd"
$location = "China East"
$containerName = "hdfiles"
$clusterName = "edxLesson2"
$clusterNodes = 2
$userName = "gdwhHD"
$password = ConvertTo-SecureString "Wangh123!@#" -AsPlainText -Force

# Create a storage account
Write-Host "Creating storage account..."
New-AzureStorageAccount -StorageAccountName $storageAccountName -Location $location

# Create a Blob storage container
Write-Host "Creating container..."
$storageAccountKey = Get-AzureStorageKey $storageAccountName | %{ $_.Primary }
$destContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
New-AzureStorageContainer -Name $containerName -Context $destContext

# Create a cluster
Write-Host "Creating HDInsight cluster..."
$credential = New-Object System.Management.Automation.PSCredential ($userName, $password)
New-AzureHDInsightCluster -Name $clusterName -Location $location -DefaultStorageAccountName "$storageAccountName.blob.core.chinacloudapi.cn" -DefaultStorageAccountKey $storageAccountKey -DefaultStorageContainerName $containerName -ClusterSizeInNodes $clusterNodes -Credential $credential -Version 3.2
Write-Host "Finished!"