# -------------------------------
# Backup folder to S3
# -------------------------------

# Variables
$LocalFolder = "C:\inetpub"          
$S3Bucket = "s3://" + (cat C:\bucket.txt) 
$LogFile = "C:\BackupLogs\S3Backup.log"

# Ensure log folder exists
$LogDir = Split-Path $LogFile
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }

# Start backup
Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - Starting S3 backup..." | Out-File -FilePath $LogFile -Append

# Run AWS CLI sync
aws s3 sync $LocalFolder $S3Bucket --exact-timestamps | Out-File -FilePath $LogFile -Append

Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - Backup completed." | Out-File -FilePath $LogFile -Append
