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
5. VPN Server ✅
6. Terminal Server (Thin Clients) ✅
7. Web Server ✅
8. Mail Server ✅
9. Database Server (MongoDB ✅, Oracle, SQL Server ✅, PostgreSQL ✅)
10. Backup Server ✅
11. Load Balancing ✅
12. Failover Cluster ✅
13. FTP Server ✅
14. Container (Docker) ✅
15. Domain Controller ✅

LLMs - Large Language Model (Fine Tuner) ✅

[Try Hack Me](https://tryhackme.com/) (1000 points)

# Usage

1. File Server
   - connect to Proxy Server
   - open file explorer and `\\<public ip of File Server>`
   - enter credential
2. Proxy Server
   - connect to File Server
   - change proxy address to `<private ip of Proxy Server>` with port 3128
   - open browser
   - visit youtube.com => allow
   - visit facebook.com => blocked
3. DNS Server
   - open Terminal
   - dog www.devspeed.com `@<public ip of dns server>`
   - dog go.devspeed.com `@<public ip of dns server>`
   - nslookup shop.devspeed.com `<public ip of dns server>`
   - nslookup mail.devspeed.com `<public ip of dns server>`
4. DHCP Server
   - dhcp client will broadcast, and get ip, default gateway, dns,... from dhcp server
   - AWS VPC DHCP is used in EC2 instance
5. VPN Server
   - connect to VPN Server
   - Open `OpenVPN GUI` to start the server
   - connect to File Server
   - change YOUR_PUBLIC_IP in `C:\Program Files\OpenVPN\config\client1.ovpn` to public ip of the VPN Server
   - Open `OpenVPN GUI` to connect to the server
   - Open powershell and type `ipconfig` and will see something like:

   ```
   Unknown adapter OpenVPN Data Channel Offload:

      Connection-specific DNS Suffix  . :
      Link-local IPv6 Address . . . . . : fe80::f729:5f67:58f2:7253%17
      IPv4 Address. . . . . . . . . . . : 10.8.0.6
      Subnet Mask . . . . . . . . . . . : 255.255.255.252
      Default Gateway . . . . . . . . . :
   ```

6. Terminal Server
   - connect to the server with RDP
7. Web Server
   - visit public dns of the server
8. Mail Server
   - open thunderbird
   - username: jame@example.local
   - password: jame
   - username: mike@example.local
   - password: mike
   - IMAP
     - hostname: `<public ip of mail server>`
     - port: 143
   - SMTP
     - hostname: `<pubic ip of mail server>`
     - port: 25
9. Database Server
   - MongoDB
     - mongosh `<public ip of mongodb server>`
   - SQL Server
     - /opt/mssql-tools18/bin/sqlcmd -S `<public ip of sql server>` -C -U sa -P mypassword@2025
   - PostgreSQL
     - psql -h `<public ip of postgresql server>` -U postgres
     - password: test
10. Backup Server
    - automatically backup "C:\inetpub" to s3 bucket every 1 minute and every night at 2 a.m.
    - check out the s3 bucket
11. Load Balancing 📌
    - manually configure load balancer (application load balancer)
    - name: devspeedlb
    - select all availability Zones and subnets
    - create target group (name: web)
      - include WebServerMailServer & Docker
    - choose 'web' as target group
    - add tcp (port 80) to inbound rule of the load balancer's security group
12. Failover Cluster
    - this ec2 instance work as a server enabling failover cluster
    - other windows server can join this domain and setup the cluster
13. FTP Server
    - use filezilla (port 21)
    - username: jame
    - password: Mypassword@2025
14. Container (Docker)
    - connect to the Docker ec2 instance
    - docker pull mcr.microsoft.com/windows/nanoserver:ltsc2022
    - docker pull mcr.microsoft.com/windows/servercore:ltsc2022 (optional)
    - docker run -it `<image>`
15. Domain Controller
    - connect to File Server
    - change dns server address to `<private ip of domain controller>`
    - join the domain 'example.local'

LLMs - Large Language Model (Fine Tuner)

- open `Fine Tuning LLM` notebook
- go to `Inference` section
- run the vllm and open-webui server
