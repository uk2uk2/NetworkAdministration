Virtual Local Area Networks (VLANs)
Overview
VLANs logically segment a physical network into multiple broadcast domains, improving security, performance, and manageability. Defined in IEEE 802.1Q, VLANs tag Ethernet frames with a VLAN ID (1-4094), allowing switches to isolate traffic without separate hardware. organizations tend to use VLANs to separate departments (e.g., VLAN 10 for staff, VLAN 20 for guests, VLAN 30 for servers) to prevent unauthorized access to sensitive data.
Key benefits:

Security: Limits broadcast domains and applies access controls.
Efficiency: Reduces unnecessary traffic; easier to manage large networks (~100 users).
Flexibility: Ports can be reassigned via software.

How VLANs Work

Tagging: Switches add a 4-byte 802.1Q tag to frames, including VLAN ID.
Access vs Trunk Ports: Access ports belong to one VLAN; trunk ports carry multiple VLANs (tagged).
Inter-VLAN Routing: Requires a Layer 3 device (router or L3 switch) to route between VLANs.
Native VLAN: Untagged traffic on trunks; default VLAN 1—change for security.

Common VLAN Commands (Cisco-like Switches)

Create VLAN: vlan 10; name STAFF.
Assign Port: interface fa0/1; switchport mode access; switchport access vlan 10.
Configure Trunk: interface fa0/24; switchport mode trunk; switchport trunk allowed vlan 10,20,30.
Show VLANs: show vlan brief.
Show Port Status: show interfaces switchport.

Troubleshooting VLANs

No Connectivity: Check port mode (show interfaces switchport), VLAN assignment, and trunk encapsulation.
Broadcast Storms: Ensure STP (Spanning Tree Protocol) is enabled (spanning-tree mode rapid-pvst).
Misconfiguration: Verify inter-VLAN routing (e.g., subinterfaces on router: interface fa0/0.10; encapsulation dot1Q 10; ip address 192.168.10.1 255.255.255.0).
Common Issues: VLAN mismatch on trunks; native VLAN inconsistencies leading to security risks.

VLAN leaks could expose data—regularly audit with show vlan.
Security Best Practices for VLANs

Private VLANs (PVLANs): Further isolate ports within a VLAN (e.g., community, isolated modes).
VLAN Hopping: Prevent with switchport mode access on user ports and disable DTP (switchport nonegotiate).
Access Control: Use ACLs on L3 interfaces (e.g., ip access-list extended DENY_GUEST; deny ip any 192.168.30.0 0.0.0.255).

Scripts for VLAN Management
Bash Script: VLAN Port Auditor (Runs on Linux, assumes SNMP or SSH access; simplify for basic checks)
#!/bin/bash
# vlan_port_auditor.sh: Lists ports and VLANs on a switch (requires snmpwalk or adjust for SSH)
switch_ip=$1
community="public"  # Replace with your SNMP community

if command -v snmpwalk >/dev/null 2>&1; then
  snmpwalk -v2c -c $community $switch_ip 1.3.6.1.4.1.9.9.68.1.2.2.1.2 | awk '{print "Port " $1 " VLAN " $NF}'
else
  echo "snmpwalk not installed. For Cisco SSH: Use expect or netmiko in Python."
fi

Python Script: VLAN Config Checker (Uses netmiko; viable if Python and pip allowed for netmiko)
from netmiko import ConnectHandler

def check_vlan_config(switch_ip, username, password):
    device = {'device_type': 'cisco_ios', 'host': switch_ip, 'username': username, 'password': password}
    try:
        conn = ConnectHandler(**device)
        vlans = conn.send_command('show vlan brief')
        print("VLAN Summary:\n", vlans)
        conn.disconnect()
    except Exception as e:
        print(f"Error: {e}")

# Usage: check_vlan_config('192.168.1.2', 'admin', 'password')

Domain Name System (DNS)
Overview
DNS translates human-readable domain names (e.g., example.com) to IP addresses, enabling communication. It's a hierarchical, distributed database using UDP/TCP port 53. In your role, DNS is paramount for internal resolution (e.g., legacy PHP apps) and external access; failures can halt operations like email or web services.
Key components:

Resolver: Client-side query handler.
Authoritative Servers: Hold zone data (e.g., NS, A, MX records).
Recursive Servers: Query on behalf of clients.
Records: A (IPv4), AAAA (IPv6), CNAME (alias), MX (mail), TXT (SPF/DKIM for security).

How DNS Works

Query Process: Local resolver checks cache, then recursive server queries root > TLD > authoritative.
Caching: TTL (Time to Live) controls how long entries are stored.
Zones: Delegated portions of namespace (e.g., your organizations domain).
Forwarding: Internal DNS forwards external queries to public servers like 8.8.8.8.

Common DNS Commands

Lookup: nslookup example.com or dig example.com.
Flush Cache: systemd-resolve --flush-caches (Linux), ipconfig /flushdns (Windows).
Check Zone: dig @server example.com AXFR (zone transfer, restricted).
Bind Config (Linux Server): Edit /etc/named.conf; rndc reload.

Troubleshooting DNS

Resolution Failure: Test with nslookup google.com 8.8.8.8; check firewall (allow UDP/TCP 53).
Slow Queries: Monitor TTL; use dig +trace example.com for path issues.
Poisoning: Enable DNSSEC (dnssec-validation yes; in Bind) to validate signatures.
Common Issues: Misconfigured hosts file, DHCP-provided wrong DNS, or legacy systems with outdated resolvers.

Anticipate: Users (~40%) may report "no internet" due to DNS—start with flush and alternate server tests.
Security Best Practices for DNS

DNSSEC: Sign zones to prevent spoofing.
Rate Limiting: Prevent DDoS amplification (rate-limit in Bind).
Split DNS: Internal views for private records.
Firewall Rules: Restrict zone transfers (allow-transfer { trusted; };).

Scripts for DNS Monitoring
Bash Script: DNS Resolution Tester
#!/bin/bash
# dns_tester.sh: Tests DNS resolution for multiple domains
domains=("google.com" "organization.local" "internal.app")
for domain in "${domains[@]}"; do
  if nslookup $domain > /dev/null 2>&1; then
    echo "$domain resolves OK: $(nslookup $domain | grep Address | tail -1)"
  else
    echo "$domain resolution failed"
  fi
done

Python Script: DNS Query Checker (No external packages)
import socket

def check_dns(domain):
    try:
        ip = socket.gethostbyname(domain)
        print(f"{domain} resolves to {ip}")
    except socket.gaierror:
        print(f"{domain} resolution failed")

domains = ["google.com", "organization.local"]
for d in domains:
    check_dns(d)

Firewalls
Overview
Firewalls enforce security policies by filtering traffic based on rules, protecting against unauthorized access. Types include packet-filtering, stateful inspection, proxy, and next-gen (NGFW) with IPS/IDS. firewalls are paramount for compliance (e.g., PCI DSS), blocking threats to legacy systems and transaction data.
Key features:

Rules: Allow/deny based on IP, port, protocol.
NAT/PAT: Hide internal IPs.
VPN Integration: Secure remote access.

How Firewalls Work

Packet Inspection: Examine headers (L3/L4) or deep packets (L7).
Stateful Tracking: Monitor connections (e.g., allow inbound only if outbound initiated).
Zones: Interfaces grouped (e.g., DMZ for web servers).
Logging: Record denied traffic for audits.

Common Firewall Commands

Linux (iptables/ufw): ufw allow 80/tcp; ufw status.
Windows: netsh advfirewall firewall add rule name="Allow HTTP" dir=in action=allow protocol=TCP localport=80.
Cisco ASA: access-list OUTSIDE_IN extended permit tcp any host 192.168.1.10 eq 443.
Check Logs: journalctl -u firewalld (Linux).

Troubleshooting Firewalls

Blocked Traffic: Test with nc -zv host port; check rules order (first match wins).
Performance Issues: Optimize rules; monitor CPU with top.
Misconfiguration: Use iptables -L -v to see hits; simulate with packet tracer tools.
Common Issues: Forgotten rules for new services, or legacy apps requiring open ports.

Anticipate: User complaints about access—verify firewall before escalating.
Security Best Practices for Firewalls

Least Privilege: Deny all, allow specific.
Regular Audits: Review rules quarterly.
Intrusion Prevention: Enable IPS modules.
Zero Trust: Segment with micro-firewalls if possible.

Scripts for Firewall Monitoring
Bash Script: Firewall Rule Checker (Linux ufw)
#!/bin/bash
# firewall_checker.sh: Lists active firewall rules
if command -v ufw >/dev/null 2>&1; then
  ufw status verbose
else
  iptables -L -v -n
fi

Python Script: Port Scan for Firewall Testing (Uses socket; basic)
import socket

def test_port(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex((host, port))
    sock.close()
    return "open" if result == 0 else "closed/filtered"

ports = [80, 443, 22]
host = "192.168.1.1"
for p in ports:
    print(f"Port {p} on {host}: {test_port(host, p)}")

Add these to your repository for reference. If you need more (e.g., OSPF, NAT), let me know!
