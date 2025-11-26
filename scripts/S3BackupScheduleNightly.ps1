# -------------------------------
# Variables
# -------------------------------
$ScriptPath = "C:\Scripts\S3Backup.ps1"    # Path to your backup script
$TaskName = "S3BackupNightly"
$TaskDescription = "Sync local folder to S3 bucket every night at 2 AM"
$TriggerTime = "02:00"                      # 24-hour format

# -------------------------------
# Create the action
# -------------------------------
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# -------------------------------
# Create the trigger
# -------------------------------
$Trigger = New-ScheduledTaskTrigger -Daily -At $TriggerTime

# -------------------------------
# Optional: Run with highest privileges
# -------------------------------
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# -------------------------------
# Register the task
# -------------------------------
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Action $Action -Trigger $Trigger -Principal $Principal -Force

Write-Host "Scheduled task '$TaskName' created to run daily at $TriggerTime"
