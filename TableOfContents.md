Table of Contents

Common Networking Commands
Reference Tables
Scripts for Automation
Troubleshooting Guides
Security Best Practices
Tools and Software Recommendations
Additional Resources

Common Networking Commands
Linux/Unix Commands

Check IP Configuration: ip addr show or ifconfig (deprecated in some distros).
Ping a Host: ping -c 4 example.com (sends 4 packets).
Traceroute: traceroute example.com or tracert on Windows.
View Routing Table: ip route show.
Check Open Ports: netstat -tuln or ss -tuln.
DNS Lookup: nslookup example.com or dig example.com.
Flush DNS Cache: systemd-resolve --flush-caches (on systemd-based systems).
Monitor Network Traffic: tcpdump -i eth0 (capture on interface eth0).
Test Port Connectivity: nc -zv example.com 80 (Netcat to check if port 80 is open).

Windows Commands

Check IP Configuration: ipconfig /all.
Ping a Host: ping -n 4 example.com.
Traceroute: tracert example.com.
View Routing Table: route print.
Check Open Ports: netstat -ano.
DNS Lookup: nslookup example.com.
Flush DNS Cache: ipconfig /flushdns.
Test Port Connectivity: Test-NetConnection example.com -Port 80 (PowerShell).
