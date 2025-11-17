# Windows Server Deployment Guide on AWS Cloud

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [File Server](#1-file-server)
3. [Proxy Server](#2-proxy-server)
4. [DNS Server](#3-dns-server)
5. [DHCP Server](#4-dhcp-server)
6. [VPN Server](#5-vpn-server)
6. [Terminal Server](#6-terminal-server)
7. [Web Server](#7-web-server)
8. [Mail Server](#8-mail-server)
9. [Database Server](#9-database-server)
10. [Backup Server](#10-backup-server)
11. [Load Balancing](#11-load-balancing)
12. [Failover Cluster](#12-failover-cluster)
13. [FTP Server](#13-ftp-server)
14. [Container (Docker)](#14-container-docker)
15. [Domain Controller](#15-domain-controller)

---

## Prerequisites

### AWS Account Setup
- Active AWS account with appropriate permissions
- VPC configured with public and private subnets
- Security groups properly configured
- Key pairs created for RDP access
- IAM roles for EC2 instances

### General Windows Server Launch Steps
1. Navigate to EC2 Dashboard in AWS Console
2. Click "Launch Instance"
3. Select Windows Server AMI (2019/2022 recommended)
4. Choose instance type based on workload
5. Configure instance details (VPC, subnet, IAM role)
6. Add storage as needed
7. Configure security groups
8. Review and launch with key pair

---

## 1. File Server

### AWS Configuration
**Instance Type:** t3.medium or larger  
**Storage:** EBS volumes with provisioned IOPS for performance  
**Security Group Ports:** 445 (SMB), 139 (NetBIOS), 3389 (RDP)

### Implementation Steps

1. **Launch Windows Server EC2 Instance**
   - Select Windows Server 2022 Datacenter
   - Attach additional EBS volumes for file storage

2. **Install File Server Role**
   ```powershell
   Install-WindowsFeature -Name FS-FileServer -IncludeManagementTools
   Install-WindowsFeature -Name FS-DFS-Namespace, FS-DFS-Replication
   ```

3. **Configure Storage**
   - Initialize and format additional EBS volumes
   - Create shared folders
   ```powershell
   New-SmbShare -Name "SharedFiles" -Path "D:\Shares" -FullAccess "Domain\Admins" -ReadAccess "Domain\Users"
   ```

4. **Enable Shadow Copies**
   ```powershell
   Enable-ComputerRestore -Drive "D:\"
   vssadmin resize shadowstorage /for=D: /on=D: /maxsize=20%
   ```

5. **Configure AWS Backup**
   - Create backup plan for EBS volumes
   - Set retention policies

### Best Practices
- Use AWS Storage Gateway for hybrid scenarios
- Implement Amazon FSx for Windows File Server for managed solution
- Enable encryption at rest using AWS KMS
- Configure NTFS permissions and share permissions

---

## 2. Proxy Server (Caching, Control Access)

### AWS Configuration
**Instance Type:** t3.medium  
**Security Group Ports:** 8080, 3128 (proxy), 3389 (RDP)

### Implementation Steps

1. **Launch Windows Server Instance**

2. **Install Proxy Server Software**
   
   **Option A: Windows Server with WinGate**
   - Download and install WinGate
   - Configure proxy settings

   **Option B: Squid for Windows**
   - Download Squid for Windows
   - Install and configure squid.conf

3. **Configure Proxy Settings**
   ```powershell
   # Example configuration for basic proxy
   netsh winhttp set proxy proxy-server="localhost:8080" bypass-list="*.local"
   ```

4. **Set Up Caching**
   - Configure cache directory on separate EBS volume
   - Set cache size limits
   - Define cache policies

5. **Access Control**
   - Configure authentication (AD integration)
   - Set up URL filtering rules
   - Implement blacklists/whitelists

6. **Configure AWS Security Group**
   - Allow inbound traffic on proxy port from specific CIDR blocks
   - Restrict outbound traffic as needed

### Best Practices
- Use AWS Network Firewall for additional security
- Consider AWS Global Accelerator for multiple regions
- Monitor with CloudWatch metrics
- Use ALB/NLB for proxy clustering

---

## 3. DNS Server

### AWS Configuration
**Instance Type:** t3.small  
**Security Group Ports:** 53 (TCP/UDP), 3389 (RDP)

### Implementation Steps

1. **Launch Windows Server Instance**
   - Place in private subnet for internal DNS

2. **Install DNS Server Role**
   ```powershell
   Install-WindowsFeature -Name DNS -IncludeManagementTools
   ```

3. **Configure DNS Zones**
   ```powershell
   # Create Primary Zone
   Add-DnsServerPrimaryZone -Name "yourdomain.local" -ReplicationScope "Forest" -PassThru
   
   # Create Reverse Lookup Zone
   Add-DnsServerPrimaryZone -NetworkID "10.0.0.0/16" -ReplicationScope "Forest"
   ```

4. **Configure Forwarders**
   ```powershell
   # Use AWS DNS or external DNS
   Add-DnsServerForwarder -IPAddress "8.8.8.8", "8.8.4.4"
   ```

5. **Integrate with AWS Route 53**
   - Create Route 53 Resolver endpoints
   - Configure conditional forwarding for AWS resources

6. **Configure DHCP Option Sets**
   - Update VPC DHCP options to point to DNS server

### Best Practices
- Deploy multiple DNS servers for redundancy
- Use Route 53 for public DNS records
- Enable DNS logging and monitoring
- Implement DNSSEC for security

---

## 4. DHCP Server

### AWS Configuration
**Instance Type:** t3.small  
**Note:** AWS VPC provides DHCP by default; custom DHCP server is optional

### Implementation Steps

1. **Launch Windows Server Instance**

2. **Install DHCP Server Role**
   ```powershell
   Install-WindowsFeature -Name DHCP -IncludeManagementTools
   Add-DhcpServerInDC -DnsName "dhcp.yourdomain.local"
   ```

3. **Configure DHCP Scope**
   ```powershell
   Add-DhcpServerv4Scope -Name "Internal Network" -StartRange 10.0.1.100 -EndRange 10.0.1.200 -SubnetMask 255.255.255.0
   
   Set-DhcpServerv4OptionValue -ScopeId 10.0.1.0 -Router 10.0.1.1
   Set-DhcpServerv4OptionValue -ScopeId 10.0.1.0 -DnsServer 10.0.1.10
   ```

4. **Configure Reservations**
   ```powershell
   Add-DhcpServerv4Reservation -ScopeId 10.0.1.0 -IPAddress 10.0.1.50 -ClientId "00-11-22-33-44-55" -Description "Print Server"
   ```

5. **Authorize DHCP Server**
   ```powershell
   Add-DhcpServerInDC -DnsName "dhcp.yourdomain.local" -IPAddress 10.0.1.10
   ```

### Best Practices
- Consider using AWS-provided DHCP for simplicity
- Deploy DHCP failover for redundancy
- Use DHCP policies for different device types
- Monitor DHCP lease utilization

---

## 5. VPN Server

### AWS Configuration
**Instance Type:** t3.small to t3.medium  
**Security Group Ports:** 1723 (PPTP), 1701 (L2TP), 500/4500 (IPSec), 443 (SSTP)  
**Elastic IP:** Required for consistent endpoint

### Implementation Steps

1. **Launch Windows Server Instance with Elastic IP**

2. **Install Remote Access Role**
   ```powershell
   Install-WindowsFeature -Name RemoteAccess -IncludeManagementTools
   Install-WindowsFeature -Name DirectAccess-VPN -IncludeManagementTools
   Install-WindowsFeature -Name Routing -IncludeManagementTools
   ```

3. **Configure VPN Server**
   ```powershell
   Install-RemoteAccess -VpnType Vpn
   ```

4. **Configure VPN Protocols**
   - Enable SSTP, L2TP/IPSec, or IKEv2
   - Configure authentication methods (RADIUS, certificates)

5. **Set Up IP Address Assignment**
   ```powershell
   Set-VpnServerConfiguration -TunnelType SSTP -PassThru
   ```

6. **Configure Routing**
   - Enable NAT for VPN clients
   - Configure routing tables

### Alternative: AWS Client VPN
Consider using AWS Client VPN for managed VPN service with better scalability and integration.

### Best Practices
- Use certificate-based authentication
- Integrate with AWS Directory Service
- Monitor connections with CloudWatch
- Consider AWS Site-to-Site VPN for office connectivity

---

## 6. Terminal Server (Thin Clients)

### AWS Configuration
**Instance Type:** t3.xlarge or larger (based on user count)  
**Security Group Ports:** 3389 (RDP), 3391 (RD Gateway)

### Implementation Steps

1. **Launch Windows Server Instance**
   - Size appropriately for concurrent users (2 vCPU + 4GB RAM per 5-10 users)

2. **Install RDS Roles**
   ```powershell
   Install-WindowsFeature -Name RDS-RD-Server -IncludeManagementTools
   Install-WindowsFeature -Name RDS-Connection-Broker -IncludeManagementTools
   Install-WindowsFeature -Name RDS-Web-Access -IncludeManagementTools
   Install-WindowsFeature -Name RDS-Gateway -IncludeManagementTools
   Install-WindowsFeature -Name RDS-Licensing -IncludeManagementTools
   ```

3. **Configure RDS Deployment**
   - Use Server Manager to create RDS deployment
   - Add RD Session Host
   - Configure RD Gateway for external access

4. **Install RDS CALs**
   - Install RDS License Server
   - Activate and install Client Access Licenses

5. **Configure Session Collections**
   ```powershell
   New-RDSessionCollection -CollectionName "Production" -SessionHost "rdsh01.yourdomain.local" -ConnectionBroker "rdcb.yourdomain.local"
   ```

6. **Set Up RemoteApp**
   ```powershell
   New-RDRemoteApp -CollectionName "Production" -DisplayName "Microsoft Word" -FilePath "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
   ```

### Best Practices
- Use RD Gateway with SSL certificates
- Deploy multiple Session Hosts with load balancing
- Use FSLogix for user profile management
- Store user data on separate file server
- Consider Amazon WorkSpaces for managed VDI

---

## 7. Web Server

### AWS Configuration
**Instance Type:** t3.medium  
**Security Group Ports:** 80 (HTTP), 443 (HTTPS), 3389 (RDP)  
**Load Balancer:** Application Load Balancer recommended

### Implementation Steps

1. **Launch Windows Server Instance**

2. **Install IIS Role**
   ```powershell
   Install-WindowsFeature -Name Web-Server -IncludeManagementTools
   Install-WindowsFeature -Name Web-Asp-Net45, Web-Net-Ext45
   Install-WindowsFeature -Name Web-Mgmt-Console
   ```

3. **Configure IIS**
   ```powershell
   # Create new website
   New-Website -Name "MyWebsite" -Port 80 -PhysicalPath "C:\inetpub\MyWebsite" -ApplicationPool "DefaultAppPool"
   
   # Create application pool
   New-WebAppPool -Name "MyAppPool"
   Set-ItemProperty IIS:\AppPools\MyAppPool -name "managedRuntimeVersion" -value "v4.0"
   ```

4. **Install SSL Certificate**
   - Request certificate from AWS Certificate Manager
   - Import certificate to IIS
   ```powershell
   New-WebBinding -Name "MyWebsite" -Protocol "https" -Port 443 -SslFlags 0
   ```

5. **Configure Application Settings**
   - Set up .NET Framework or .NET Core
   - Configure connection strings
   - Set permissions for application folders

6. **Set Up Application Load Balancer**
   - Create target group with health checks
   - Register EC2 instances
   - Configure listener rules

### Best Practices
- Use AWS Certificate Manager for SSL certificates
- Enable CloudFront for CDN
- Configure auto-scaling for traffic spikes
- Use Amazon RDS instead of local database
- Enable AWS WAF for security

---

## 8. Mail Server

### AWS Configuration
**Instance Type:** t3.medium  
**Security Group Ports:** 25 (SMTP), 110 (POP3), 143 (IMAP), 587 (Submission), 993 (IMAPS), 995 (POP3S)  
**Elastic IP:** Required  
**Note:** AWS blocks port 25 by default; request removal

### Implementation Steps

1. **Request Port 25 Unblocking**
   - Submit request to AWS Support
   - Provide reverse DNS setup

2. **Launch Windows Server Instance with Elastic IP**

3. **Install SMTP Server**
   ```powershell
   Install-WindowsFeature -Name SMTP-Server -IncludeManagementTools
   ```

4. **Install Third-Party Mail Server**
   
   **Option A: hMailServer (Free)**
   - Download and install hMailServer
   - Configure domains and accounts
   - Set up SSL/TLS certificates

   **Option B: Microsoft Exchange Server**
   - More complex but full-featured
   - Install prerequisites
   - Install Exchange Server
   - Configure mailbox databases

5. **Configure DNS Records**
   - MX records pointing to Elastic IP
   - SPF, DKIM, and DMARC records
   - Reverse DNS (PTR) record

6. **Configure Security**
   - Enable spam filtering
   - Configure antivirus scanning
   - Set up SSL/TLS encryption
   - Configure relay restrictions

### Alternative: Amazon SES
Consider using Amazon Simple Email Service (SES) for sending emails, which provides better deliverability and doesn't require managing infrastructure.

### Best Practices
- Use Amazon WorkMail for managed email service
- Implement proper email security (SPF, DKIM, DMARC)
- Configure backup MX records
- Monitor email queues and logs
- Use SES for transactional emails

---

## 9. Database Server

### AWS Configuration
**Instance Type:** r5.large or larger (memory-optimized)  
**Storage:** EBS with provisioned IOPS or io2  
**Security Group Ports:** 
- MongoDB: 27017
- Oracle: 1521
- SQL Server: 1433
- PostgreSQL: 5432

### Implementation Steps

#### SQL Server

1. **Launch Windows Server Instance**
   - Use memory-optimized instance type
   - Attach high-performance EBS volumes

2. **Install SQL Server**
   - Download SQL Server (Developer/Standard/Enterprise)
   - Run setup.exe
   ```powershell
   # Silent installation example
   Setup.exe /Q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSYSADMINACCOUNTS="DOMAIN\SQLAdmins" /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM"
   ```

3. **Configure SQL Server**
   ```sql
   -- Enable remote connections
   EXEC sys.sp_configure 'remote access', 1;
   RECONFIGURE;
   
   -- Configure max memory
   EXEC sys.sp_configure 'max server memory (MB)', 8192;
   RECONFIGURE;
   ```

4. **Set Up Backups**
   - Configure SQL Server backup to S3
   - Use SQL Server native backup to S3
   ```sql
   BACKUP DATABASE [MyDB] TO URL = 's3://my-bucket/backups/MyDB.bak'
   ```

#### PostgreSQL

1. **Install PostgreSQL**
   - Download PostgreSQL installer for Windows
   - Run installation wizard

2. **Configure PostgreSQL**
   ```bash
   # Edit postgresql.conf
   listen_addresses = '*'
   max_connections = 100
   shared_buffers = 2GB
   
   # Edit pg_hba.conf for authentication
   host all all 0.0.0.0/0 md5
   ```

3. **Create Database**
   ```sql
   CREATE DATABASE myapp;
   CREATE USER appuser WITH ENCRYPTED PASSWORD 'password';
   GRANT ALL PRIVILEGES ON DATABASE myapp TO appuser;
   ```

#### MongoDB

1. **Install MongoDB**
   - Download MongoDB Community Server for Windows
   - Install as Windows Service

2. **Configure MongoDB**
   ```yaml
   # Edit mongod.cfg
   net:
     port: 27017
     bindIp: 0.0.0.0
   security:
     authorization: enabled
   storage:
     dbPath: D:\MongoDB\data
   ```

3. **Create Admin User**
   ```javascript
   use admin
   db.createUser({
     user: "admin",
     pwd: "password",
     roles: [ { role: "root", db: "admin" } ]
   })
   ```

### Alternative: Amazon RDS
Consider using Amazon RDS for SQL Server, PostgreSQL, or Oracle for fully managed database service with automated backups, patching, and high availability.

### Best Practices
- Use Amazon RDS for managed database services
- Enable automated backups
- Use Multi-AZ deployments for high availability
- Store database files on separate EBS volumes
- Enable encryption at rest
- Use IAM database authentication where possible
- Monitor with CloudWatch and Performance Insights

---

## 10. Backup Server

### AWS Configuration
**Instance Type:** t3.medium  
**Storage:** Large EBS volumes or S3 integration  
**IAM Role:** Permissions for S3, EBS snapshots

### Implementation Steps

1. **Launch Windows Server Instance**

2. **Install Windows Server Backup**
   ```powershell
   Install-WindowsFeature -Name Windows-Server-Backup -IncludeManagementTools
   ```

3. **Configure AWS Backup**
   - Set up AWS Backup service
   - Create backup plans
   - Assign resources to backup plans

4. **Install Third-Party Backup Software**
   
   **Option A: Veeam Backup**
   - Download Veeam Backup & Replication
   - Install and configure
   - Set up backup jobs to S3

   **Option B: Windows Server Backup to S3**
   ```powershell
   # Create backup policy
   $Policy = New-WBPolicy
   $Target = New-WBBackupTarget -VolumePath "D:"
   Add-WBBackupTarget -Policy $Policy -Target $Target
   Add-WBVolume -Policy $Policy -Volume (Get-WBVolume -VolumePath "C:")
   Set-WBSchedule -Policy $Policy -Schedule 02:00
   Set-WBPolicy -Policy $Policy
   ```

5. **Configure S3 Lifecycle Policies**
   - Transition to S3 Glacier for long-term retention
   - Set expiration policies

6. **Set Up EBS Snapshot Automation**
   ```powershell
   # Using AWS PowerShell
   New-EC2Snapshot -VolumeId vol-12345678 -Description "Daily Backup"
   ```

### Best Practices
- Use AWS Backup for centralized backup management
- Store backups in S3 with versioning enabled
- Implement 3-2-1 backup strategy
- Test backup restoration regularly
- Use S3 Glacier for long-term archival
- Enable cross-region backup replication

---

## 11. Load Balancing

### AWS Configuration
**Service:** Application Load Balancer (ALB) or Network Load Balancer (NLB)  
**Target Group:** Multiple Windows Server instances

### Implementation Steps

1. **Launch Multiple Windows Server Instances**
   - Deploy identical servers in different availability zones
   - Install and configure web application on all instances

2. **Create Target Group**
   - Navigate to EC2 > Target Groups
   - Create target group with health check settings
   ```
   Protocol: HTTP/HTTPS
   Port: 80/443
   Health Check Path: /health
   Health Check Interval: 30 seconds
   Healthy Threshold: 2
   Unhealthy Threshold: 2
   ```

3. **Create Application Load Balancer**
   - Choose ALB for HTTP/HTTPS traffic
   - Select availability zones
   - Configure security groups
   - Add listener rules
   - Register target group

4. **Configure Session Persistence**
   - Enable sticky sessions if needed
   - Configure duration

5. **Set Up Auto Scaling Group**
   ```powershell
   # Using AWS CLI or CloudFormation
   # Define launch template
   # Create auto-scaling group
   # Configure scaling policies
   ```

6. **Install and Configure IIS ARR (Alternative)**
   ```powershell
   # For Windows-based load balancing
   Install-WindowsFeature Web-Server -IncludeManagementTools
   # Install Application Request Routing
   # Configure server farms
   ```

### Best Practices
- Use ALB for HTTP/HTTPS traffic
- Use NLB for TCP/UDP traffic or ultra-low latency
- Deploy instances across multiple availability zones
- Configure proper health checks
- Enable access logs for troubleshooting
- Use CloudWatch for monitoring
- Implement auto-scaling based on metrics

---

## 12. Failover Cluster

### AWS Configuration
**Instance Type:** r5.xlarge or larger  
**Storage:** Shared storage using FSx for Windows or S3  
**Network:** Placement groups for low latency  
**Security Group:** Allow cluster communication ports

### Implementation Steps

1. **Launch Multiple Windows Server Instances**
   - Deploy in same VPC, different availability zones
   - Use placement group for low latency

2. **Install Failover Clustering Feature**
   ```powershell
   Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
   ```

3. **Configure Shared Storage**
   
   **Option A: Amazon FSx for Windows File Server**
   - Create FSx file system
   - Mount on all cluster nodes
   
   **Option B: EBS Multi-Attach (io2 only)**
   - Attach same EBS volume to multiple instances
   - Initialize as cluster shared volume

4. **Create Failover Cluster**
   ```powershell
   # Validate cluster configuration
   Test-Cluster -Node "Node1", "Node2"
   
   # Create cluster
   New-Cluster -Name "MyCluster" -Node "Node1", "Node2" -StaticAddress "10.0.1.100" -NoStorage
   ```

5. **Configure Cluster Quorum**
   ```powershell
   Set-ClusterQuorum -NodeAndFileShareMajority "\\FSx\Witness"
   ```

6. **Add Clustered Role**
   ```powershell
   # For SQL Server
   Add-ClusterServerRole -Name "SQL-Cluster" -Storage "Cluster Disk 1"
   ```

7. **Configure Secondary Private IP**
   - Assign secondary private IP to ENI
   - Configure in cluster as virtual IP

### Common Cluster Types in AWS

#### SQL Server Failover Cluster
- Use FSx for shared storage
- Configure SQL Server on cluster nodes
- Set up availability group for database replication

#### File Server Cluster
- Use FSx or S3 for storage
- Configure highly available file shares

### Best Practices
- Use Amazon FSx for Windows File Server for shared storage
- Deploy cluster nodes in different availability zones
- Use Elastic IP or Network Load Balancer for client access
- Monitor cluster health with CloudWatch
- Regular testing of failover scenarios
- Consider Amazon RDS Multi-AZ for database clustering

---

## 13. FTP Server

### AWS Configuration
**Instance Type:** t3.small to t3.medium  
**Security Group Ports:** 21 (FTP Control), 20 (FTP Data), 990 (FTPS), Range for Passive Mode (e.g., 50000-50100)  
**Elastic IP:** Required for consistent access

### Implementation Steps

1. **Launch Windows Server Instance with Elastic IP**

2. **Install FTP Server Role**
   ```powershell
   Install-WindowsFeature -Name Web-Ftp-Server -IncludeManagementTools
   Install-WindowsFeature -Name Web-Ftp-Service
   ```

3. **Configure FTP Site**
   ```powershell
   # Create FTP site
   New-WebFtpSite -Name "FTP Site" -Port 21 -PhysicalPath "D:\FTP"
   
   # Configure authentication
   Set-WebConfigurationProperty -Filter /system.ftpServer/security/authentication/basicAuthentication -PSPath IIS:\ -Location "FTP Site" -Name enabled -Value $true
   ```

4. **Configure Passive Mode**
   ```powershell
   # Set passive port range
   Set-WebConfigurationProperty -Filter /system.ftpServer/firewallSupport -PSPath IIS:\ -Name lowDataChannelPort -Value 50000
   Set-WebConfigurationProperty -Filter /system.ftpServer/firewallSupport -PSPath IIS:\ -Name highDataChannelPort -Value 50100
   
   # Set external IP
   Set-WebConfigurationProperty -Filter /system.ftpServer/firewallSupport -PSPath IIS:\ -Name externalIp4Address -Value "YOUR_ELASTIC_IP"
   ```

5. **Enable FTPS (FTP over SSL)**
   ```powershell
   # Import SSL certificate
   $cert = New-SelfSignedCertificate -DnsName "ftp.yourdomain.com" -CertStoreLocation cert:\LocalMachine\My
   
   # Bind certificate to FTP site
   Set-WebConfigurationProperty -Filter /system.ftpServer/security/ssl -PSPath IIS:\ -Location "FTP Site" -Name serverCertHash -Value $cert.Thumbprint
   Set-WebConfigurationProperty -Filter /system.ftpServer/security/ssl -PSPath IIS:\ -Location "FTP Site" -Name ssl128 -Value $true
   ```

6. **Configure User Access**
   ```powershell
   # Create FTP user
   New-LocalUser -Name "ftpuser" -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
   
   # Set folder permissions
   $acl = Get-Acl "D:\FTP"
   $permission = "ftpuser","FullControl","Allow"
   $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
   $acl.SetAccessRule($accessRule)
   Set-Acl "D:\FTP" $acl
   ```

7. **Configure Security Group**
   - Allow port 21 (control)
   - Allow passive port range (50000-50100)
   - Restrict source IPs if possible

### Alternative: AWS Transfer Family
Consider using AWS Transfer Family (SFTP, FTPS, FTP) for fully managed file transfer service with S3 backend.

### Best Practices
- Use FTPS or SFTP instead of plain FTP
- Use AWS Transfer Family for managed solution
- Store files on S3 via AWS Transfer Family
- Limit source IP addresses in security groups
- Use separate EBS volume for FTP data
- Monitor with CloudWatch logs
- Regular security audits

---

## 14. Container (Docker)

### AWS Configuration
**Instance Type:** t3.medium or larger  
**Operating System:** Windows Server 2019/2022 with Containers  
**Security Group Ports:** Custom ports based on containerized applications

### Implementation Steps

1. **Launch Windows Server Instance**
   - Choose Windows Server 2019/2022
   - Select version with container support

2. **Install Docker**
   ```powershell
   # Install Docker provider
   Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
   
   # Install Docker
   Install-Package -Name docker -ProviderName DockerMsftProvider -Force
   
   # Restart computer
   Restart-Computer -Force
   ```

3. **Verify Docker Installation**
   ```powershell
   docker version
   docker info
   ```

4. **Pull Windows Container Images**
   ```powershell
   # Pull Windows Server Core base image
   docker pull mcr.microsoft.com/windows/servercore:ltsc2022
   
   # Pull .NET Framework image
   docker pull mcr.microsoft.com/dotnet/framework/aspnet:4.8
   ```

5. **Create Dockerfile**
   ```dockerfile
   FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8
   WORKDIR /inetpub/wwwroot
   COPY ./app .
   EXPOSE 80
   ```

6. **Build and Run Container**
   ```powershell
   # Build image
   docker build -t mywebapp:v1 .
   
   # Run container
   docker run -d -p 80:80 --name webapp mywebapp:v1
   
   # View running containers
   docker ps
   ```

7. **Push to Amazon ECR**
   ```powershell
   # Authenticate to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
   
   # Tag image
   docker tag mywebapp:v1 ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/mywebapp:v1
   
   # Push image
   docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/mywebapp:v1
   ```

### Alternative: Amazon ECS for Windows Containers
Use Amazon Elastic Container Service (ECS) or Amazon Elastic Kubernetes Service (EKS) with Windows support for orchestrated container deployments.

### ECS Windows Container Setup

1. **Create ECS Cluster**
   - Choose EC2 launch type with Windows AMI
   - Or use Fargate for Windows (when available)

2. **Create Task Definition**
   ```json
   {
     "family": "windows-webapp",
     "containerDefinitions": [
       {
         "name": "webapp",
         "image": "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/mywebapp:v1",
         "memory": 2048,
         "cpu": 1024,
         "portMappings": [
           {
             "containerPort": 80,
             "protocol": "tcp"
           }
         ]
       }
     ],
     "requiresCompatibilities": ["EC2"],
     "networkMode": "awsvpc",
     "runtimePlatform": {
       "operatingSystemFamily": "WINDOWS_SERVER_2022_CORE"
     }
   }
   ```

3. **Create ECS Service**
   - Deploy task definition
   - Configure load balancer
   - Set desired task count

### Best Practices
- Use Amazon ECS or EKS for production container orchestration
- Store images in Amazon ECR
- Use Windows Server Core or Nano Server base images
- Implement CI/CD with AWS CodePipeline
- Monitor containers with CloudWatch Container Insights
- Use Task roles for AWS service access
- Regular image security scanning

---

## 15. Domain Controller

### AWS Configuration
**Instance Type:** t3.medium or larger  
**Security Group Ports:** 
- 53 (DNS TCP/UDP)
- 88 (Kerberos)
- 135 (RPC)
- 139, 445 (SMB)
- 389, 636 (LDAP,