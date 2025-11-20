# Start-Transcript -Path "C:\userdata.log" -Append

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install mongodb -y
choco install mongodb-shell -y
Invoke-WebRequest https://raw.githubusercontent.com/james5635/windows_server_assignment/refs/heads/main/config/mongod.cfg -OutFile "C:\Program Files\MongoDB\Server\8.2\bin\mongod.cfg"
Restart-Service MongoDB

# Stop-Transcript