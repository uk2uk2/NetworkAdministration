# Network Administrator Information Repository

## Table of Contents
1. [Common Networking Commands](#common-networking-commands)
2. [Reference Tables](#reference-tables)
3. [Scripts for Automation](#scripts-for-automation)
4. [Troubleshooting Guides](#troubleshooting-guides)
5. [Security Best Practices](#security-best-practices)
6. [Tools and Software Recommendations](#tools-and-software-recommendations)
7. [Additional Resources](#additional-resources)

## Common Networking Commands

### Linux/Unix Commands
- **Check IP Configuration**: `ip addr show` or `ifconfig` (deprecated in some distros).
- **Ping a Host**: `ping -c 4 example.com` (sends 4 packets).
- **Traceroute**: `traceroute example.com` or `tracert` on Windows.
- **View Routing Table**: `ip route show`.
- **Check Open Ports**: `netstat -tuln` or `ss -tuln`.
- **DNS Lookup**: `nslookup example.com` or `dig example.com`.
- **Flush DNS Cache**: `systemd-resolve --flush-caches` (on systemd-based systems).
- **Monitor Network Traffic**: `tcpdump -i eth0` (capture on interface eth0).
- **Test Port Connectivity**: `nc -zv example.com 80` (Netcat to check if port 80 is open).

### Windows Commands
- **Check IP Configuration**: `ipconfig /all`.
- **Ping a Host**: `ping -n 4 example.com`.
- **Traceroute**: `tracert example.com`.
- **View Routing Table**: `route print`.
- **Check Open Ports**: `netstat -ano`.
- **DNS Lookup**: `nslookup example.com`.
- **Flush DNS Cache**: `ipconfig /flushdns`.
- **Test Port Connectivity**: `Test-NetConnection example.com -Port 80` (PowerShell).

## Reference Tables

### Common TCP/UDP Ports
| Port | Protocol | Service          | Description                  |
|------|----------|------------------|------------------------------|
| 20   | TCP     | FTP Data        | File Transfer Protocol data |
| 21   | TCP     | FTP Control     | File Transfer Protocol control |
| 22   | TCP     | SSH             | Secure Shell                |
| 23   | TCP     | Telnet          | Telnet protocol             |
| 25   | TCP     | SMTP            | Simple Mail Transfer Protocol |
| 53   | UDP     | DNS             | Domain Name System          |
| 80   | TCP     | HTTP            | Hypertext Transfer Protocol |
| 443  | TCP     | HTTPS           | HTTP Secure                 |
| 3389 | TCP     | RDP             | Remote Desktop Protocol     |

### Subnet Mask Quick Reference
| CIDR | Subnet Mask      | Usable Hosts | Description          |
|------|------------------|--------------|----------------------|
| /24  | 255.255.255.0   | 254         | Standard Class C    |
| /25  | 255.255.255.128 | 126         | Half of /24         |
| /26  | 255.255.255.192 | 62          | Quarter of /24      |
| /27  | 255.255.255.224 | 30          | Small subnet        |
| /28  | 255.255.255.240 | 14          | Very small subnet   |
| /29  | 255.255.255.248 | 6           | Tiny subnet         |
| /30  | 255.255.255.252 | 2           | Point-to-point      |

### HTTP Status Codes
| Code | Description                  | Common Use Case              |
|------|------------------------------|------------------------------|
| 200  | OK                          | Successful request          |
| 301  | Moved Permanently           | Permanent redirect          |
| 400  | Bad Request                 | Invalid syntax              |
| 401  | Unauthorized                | Authentication required     |
| 403  | Forbidden                   | Access denied               |
| 404  | Not Found                   | Resource missing            |
| 500  | Internal Server Error       | Server-side error           |
| 502  | Bad Gateway                 | Invalid upstream response   |

## Scripts for Automation

### Bash Script: Simple Ping Sweep (Scan for Live Hosts on a Subnet)
```bash
#!/bin/bash
# Usage: ./ping_sweep.sh 192.168.1

subnet=$1
for i in {1..254}; do
  ping -c 1 -W 1 $subnet.$i &> /dev/null
  if [ $? -eq 0 ]; then
    echo "$subnet.$i is up"
  fi
done
```

### Python Script: Port Scanner (Basic)
```python
import socket
import sys

def scan_ports(host, ports):
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((host, port))
        if result == 0:
            print(f"Port {port} is open")
        sock.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python port_scanner.py <host> [ports...]")
        sys.exit(1)
    host = sys.argv[1]
    ports = [int(p) for p in sys.argv[2:]] if len(sys.argv) > 2 else range(1, 1025)
    scan_ports(host, ports)
```

### Bash Script: Backup Router Config (Using Expect for Cisco-like Devices)
```bash
#!/usr/bin/expect -f
set hostname [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

spawn ssh $username@$hostname
expect "password:"
send "$password\r"
expect "#"
send "show running-config\r"
expect "#"
set output $expect_out(buffer)
send "exit\r"

set file [open "backup_$hostname.cfg" w]
puts $file $output
close $file
```

### Python Script: Monitor Network Interface Traffic
```python
import psutil
import time

def monitor_interface(interface, duration=60):
    start_time = time.time()
    while time.time() - start_time < duration:
        stats = psutil.net_io_counters(pernic=True).get(interface)
        if stats:
            print(f"Bytes sent: {stats.bytes_sent}, Bytes received: {stats.bytes_recv}")
        time.sleep(5)

if __name__ == "__main__":
    monitor_interface("eth0")  # Replace with your interface name
```

## Troubleshooting Guides

### Network Connectivity Issues
1. **No Internet Access**:
   - Check physical connections (cables, Wi-Fi signal).
   - Verify IP config: Ensure valid IP, gateway, DNS.
   - Ping loopback (127.0.0.1), then gateway, then external (8.8.8.8).
   - Check firewall rules or proxy settings.

2. **Slow