$clusterName = "clusterHive"

# Run a Hive job to create and load a table
$hiveQL = "DROP TABLE webactivity;CREATE EXTERNAL TABLE webactivity(log_date STRING, page_hits INT, bytes_recvd INT, bytes_sent INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ' ' STORED AS TEXTFILE LOCATION '/data/webactivity'; INSERT INTO TABLE webactivity SELECT log_date, COUNT(*), SUM(sc_bytes), SUM(cs_bytes) FROM cleanlog GROUP BY log_date  ORDER BY log_date;"
$jobDef = New-AzureHDInsightHiveJobDefinition -Query $hiveQL -JobName "create summary table webactivity" -RunAsFile
$hiveJob = Start-AzureHDInsightJob -Cluster $clusterName -JobDefinition $jobDef
Write-Host "HiveQL job submitted..."
Wait-AzureHDInsightJob -Job $hiveJob -WaitTimeoutInSeconds 3600
Get-AzureHDInsightJobOutput -Cluster $clusterName -JobId $hiveJob.JobId -StandardError

# Run a Hive query to retrieve data from a table
$hiveQL = "SELECT * FROM webactivity;"
Use-AzureHDInsightCluster $clusterName
Invoke-Hive -Query $hiveQL