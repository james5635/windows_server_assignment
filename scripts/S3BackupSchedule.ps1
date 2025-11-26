# -------------------------------
# Variables
# -------------------------------
$ScriptPath = "C:\S3Backup.ps1"    
$TaskName = "S3Backup"
$TaskDescription = "Sync local folder to S3 bucket"
$Time = 1
# -------------------------------
# Create the action
# -------------------------------
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

# -------------------------------
# Create the trigger 
# -------------------------------
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes $Time) 

# -------------------------------
# Optional: Run with highest privileges
# -------------------------------
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# -------------------------------
# Register the task
# -------------------------------
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -Action $Action -Trigger $Trigger -Principal $Principal -Force

Write-Host "Scheduled task '$TaskName' created to run every $Time minutes"
