# Instruction

```txt
Windows/Linux - Cloud
1. File Server
2. Proxy Server (Caching, Control Access)
3. DNS Server
4. DHCP Server
5. VPN Server
6. Terminal Server (Thin Clients)
7. Web Server
8. Mail Server
9. Database Server (MongoDB, Oracle, SQL Server, PostgreSQL)
10. Backup Server
11. Load Balancing
12. Failover Cluster
13. FTP Server
14. Container (Docker)
15. Domain Controller
LLMs - Large Language Model  (Fine Tuner)
```

# To-do List

1. File Server ✅
2. Proxy Server (Caching, Control Access) ✅
3. DNS Server ✅
4. DHCP Server ✅
5. VPN Server :todo
6. Terminal Server (Thin Clients) ✅
7. Web Server ✅
8. Mail Server ✅
9. Database Server (MongoDB ✅, Oracle, SQL Server ✅, PostgreSQL ✅)
10. Backup Server ✅
11. Load Balancing ✅
12. Failover Cluster
13. FTP Server ✅
14. Container (Docker) ✅
15. Domain Controller ✅

LLMs - Large Language Model (Fine Tuner)

# Usage
1. File Server
   - connect to Proxy Server
   - open file explorer and \\<public ip of File Server>
   - enter credential
2. Proxy Server
   - connect to File Server
   - change proxy address to <private ip of Proxy Server> with port 3128 
   - open browser
   - visit youtube.com => allow
   - visit facebook.com => blocked
3. DNS Server
   - open Terminal
   - dog www.devspeed.com @<public ip of dns server>
   - dog go.devspeed.com @<public ip of dns server>
   - nslookup shop.devspeed.com <public ip of dns server>
   - nslookup mail.devspeed.com <public ip of dns server>
4. DHCP Server
   - dhcp client will broadcast, and get ip, default gateway, dns,... from dhcp server
   - AWS VPC DHCP is used in EC2 instance
5. VPN Server
   - 
10. Backup Server
    - automatically backup "C:\inetpub" to s3 bucket every 1 minute and every night at 2 a.m.
    - check out the s3 bucket
11. Load Balancing
    - manually configure load balancer (application load balancer)
    - name: devspeedlb
    - select all availability Zones and subnets
    - create target group (name: web)
      - include WebServerMailServer & Docker
    - choose 'web' as target group
    - add tcp (port 80) to inbound rule of the load balancer's security group 
13. FTP Server
    - use filezilla (port 21)
    - username: jame
    - password: Mypassword@2025
14. Container (Docker)
    - connect to the windows ec2 instance
    - docker pull mcr.microsoft.com/windows/nanoserver:ltsc2022
    - docker pull mcr.microsoft.com/windows/servercore:ltsc2022 (optional)
    - docker run -it <image>
15. Domain Controller
    - connect to File Server
    - change dns server address to <private ip of domain controller>
    - join the domain 'example.local'