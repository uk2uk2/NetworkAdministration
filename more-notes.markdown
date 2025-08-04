# Fundamental Networking Concepts

## Open Shortest Path First (OSPF)

### Overview
OSPF is a link-state routing protocol used for routing within an autonomous system. It uses Dijkstra's algorithm to calculate the shortest path tree and supports fast convergence, load balancing, and area segmentation for scalability.

**Key Features**:
- **Areas**: Divides network into areas (e.g., backbone area 0) to reduce routing table size.
- **Link-State Advertisements (LSAs)**: Flooded to share topology information.
- **Metrics**: Based on cost (inverse of bandwidth).
- **Authentication**: Supports MD5 or SHA for security.

### How OSPF Works
1. **Neighbor Discovery**: Hello packets on multicast 224.0.0.5.
2. **Adjacency Formation**: Exchange Database Description (DD), Link State Request (LSR), Update (LSU).
3. **Topology Calculation**: Builds LSDB, runs SPF algorithm.
4. **Route Summarization**: At area borders.

### Common OSPF Commands (Cisco-like Routers)
- **Enable OSPF**: `router ospf 1`
- **Advertise Network**: `network 192.168.1.0 0.0.0.255 area 0`
- **Show Neighbors**: `show ip ospf neighbor`
- **Show Database**: `show ip ospf database`

### Troubleshooting OSPF
- **No Adjacency**: Check area mismatch, MTU, authentication.
- **Route Missing**: Verify LSAs (`show ip ospf database`), area types (stub, NSSA).
- **Flapping**: Monitor hello/dead timers (default 10s/40s).
- **Common Issues**: Incorrect subnet masks, passive interfaces.

### Security Best Practices
- **Authentication**: `ip ospf authentication message-digest; ip ospf message-digest-key 1 md5 <key>`
- **Passive Interfaces**: `passive-interface default` to prevent unnecessary hellos.
- **Area Filtering**: Use `area 1 filter-list` for control.

### Scripts for OSPF Monitoring
#### Bash Script: OSPF Neighbor Checker
```bash
#!/bin/bash
# ospf_neighbor_checker.sh: Checks OSPF neighbors via SSH
router_ip=$1
username=$2
password=$3

if command -v sshpass >/dev/null 2>&1; then
  sshpass -p "$password" ssh -o StrictHostKeyChecking=no $username@$router_ip 'show ip ospf neighbor'
else
  echo "sshpass not installed. Manually SSH and run 'show ip ospf neighbor'."
fi
```

#### Python Script: OSPF Database Viewer
```python
from netmiko import ConnectHandler

def view_ospf_database(router_ip, username, password):
    device = {'device_type': 'cisco_ios', 'host': router_ip, 'username': username, 'password': password}
    try:
        conn = ConnectHandler(**device)
        output = conn.send_command('show ip ospf database')
        print("OSPF Database:\n", output)
        conn.disconnect()
    except Exception as e:
        print(f"Error: {e}")

# Usage: view_ospf_database('192.168.1.1', 'admin', 'password')
```

## Dynamic Host Configuration Protocol (DHCP)

### Overview
DHCP automates IP address assignment, providing IPs, subnet masks, gateways, and DNS servers to clients. It uses UDP ports 67 (server) and 68 (client) and is essential for managing dynamic IP allocation in networks.

**Key Components**:
- **Server**: Manages pools and leases.
- **Client**: Requests configuration.
- **Relay Agent**: Forwards requests across subnets.
- **Options**: Additional params like DNS (option 6), domain (option 15).

### How DHCP Works
1. **Discover**: Client broadcasts DHCPOFFER.
2. **Offer**: Server responds with available IP.
3. **Request**: Client requests the offered IP.
4. **Acknowledge**: Server confirms lease.

### Common DHCP Commands
- **Linux Server (isc-dhcp-server)**: Edit `/etc/dhcp/dhcpd.conf`; `systemctl restart isc-dhcp-server`
- **Show Leases**: `cat /var/lib/dhcp/dhcpd.leases`
- **Windows**: `ipconfig /release; ipconfig /renew`
- **Cisco Router as Server**: `ip dhcp pool NETWORK; network 192.168.1.0 255.255.255.0`

### Troubleshooting DHCP
- **No IP Assigned**: Check scope exhaustion, relay config (`ip helper-address`).
- **Conflicts**: Monitor logs for duplicates.
- **Rogue Servers**: Use DHCP snooping on switches (`ip dhcp snooping`).
- **Common Issues**: Firewall blocking UDP 67/68, incorrect gateway.

### Security Best Practices
- **DHCP Snooping**: `ip dhcp snooping vlan 10` to prevent unauthorized servers.
- **Option 82**: Insert relay info for tracking.
- **Reservations**: Static assignments for critical devices.

### Scripts for DHCP Monitoring
#### Bash Script: DHCP Lease Viewer
```bash
#!/bin/bash
# dhcp_lease_viewer.sh: Views DHCP leases on Linux server
if [ -f /var/lib/dhcp/dhcpd.leases ]; then
  cat /var/lib/dhcp/dhcpd.leases | grep -E 'lease|binding'
else
  echo "DHCP leases file not found."
fi
```

#### Python Script: DHCP Client Simulator
```python
import socket

def simulate_dhcp_discover():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.sendto(b'DHCP DISCOVER SIMULATION', ('255.255.255.255', 67))
        print("DHCP Discover sent.")
        sock.close()
    except Exception as e:
        print(f"Error: {e}")

simulate_dhcp_discover()
```

## Virtual Private Networks (VPNs)

### Overview
VPNs create secure tunnels over public networks, encrypting traffic for remote access or site-to-site connectivity. Common protocols: IPsec, OpenVPN, WireGuard.

**Key Features**:
- **Encryption**: AES for confidentiality.
- **Authentication**: Certificates or PSK.
- **Tunneling**: Encapsulates packets.
- **Split Tunneling**: Routes only specific traffic through VPN.

### How VPNs Work
1. **Initiation**: Client connects to server.
2. **Key Exchange**: IKE for IPsec.
3. **Tunnel Establishment**: Data encrypted and sent.
4. **Teardown**: On disconnect.

### Common VPN Commands
- **OpenVPN Server**: Edit `/etc/openvpn/server.conf`; `systemctl start openvpn-server@server`
- **Client Connect**: `openvpn --config client.ovpn`
- **IPsec (strongSwan)**: `ipsec up connection-name`
- **Check Status**: `ipsec status`

### Troubleshooting VPNs
- **Connection Failure**: Check ports (UDP 1194 for OpenVPN), certificates.
- **Slow Performance**: Verify MTU, encryption overhead.
- **Routing Issues**: Ensure routes pushed correctly.
- **Common Issues**: NAT traversal problems, mismatched policies.

### Security Best Practices
- **Strong Encryption**: Use AES-256, SHA-256.
- **MFA**: For user authentication.
- **Kill Switch**: Prevent leaks.
- **Logging**: Minimal to protect privacy.

### Scripts for VPN Monitoring
#### Bash Script: VPN Status Checker
```bash
#!/bin/bash
# vpn_status_checker.sh: Checks OpenVPN status
if command -v systemctl >/dev/null 2>&1; then
  systemctl status openvpn-server@server
else
  echo "systemctl not available."
fi
```

#### Python Script: VPN Connection Tester
```python
import subprocess

def test_vpn_connection(interface='tun0'):
    try:
        output = subprocess.run(['ip', 'link', 'show', interface], capture_output=True, text=True)
        if "UP" in output.stdout:
            print(f"{interface} is up.")
        else
            print(f"{interface} is down.")
    except:
        print("Error checking VPN interface.")

test_vpn_connection()
```

## Wireless Networking

### Overview
Wireless networking uses radio waves for connectivity, based on IEEE 802.11 standards (e.g., Wi-Fi 6/802.11ax). Essential for mobile users, but prone to interference and security risks.

**Key Features**:
- **Bands**: 2.4GHz (longer range), 5GHz (faster).
- **Security**: WPA3 for encryption.
- **SSID**: Network name.
- **Channels**: To avoid overlap (1,6,11 on 2.4GHz).

### How Wireless Networking Works
1. **Association**: Client scans and joins AP.
2. **Authentication**: Open, WPA-PSK, 802.1X.
3. **Data Transmission**: Frames with management, control, data.
4. **Roaming**: Handover between APs.

### Common Wireless Commands
- **Linux**: `iwlist wlan0 scan`; `wpa_supplicant -c wpa.conf -i wlan0`
- **Windows**: `netsh wlan show networks`
- **Cisco AP**: `show dot11 associations`
- **Change Channel**: `iwconfig wlan0 channel 6`

### Troubleshooting Wireless
- **No Signal**: Check channel overlap, interference (`iwlist scan`).
- **Slow Speed**: Test with `iperf`; adjust power.
- **Disconnects**: Monitor signal strength (RSSI > -70dBm).
- **Common Issues**: Hidden SSID, MAC filtering.

### Security Best Practices
- **WPA3**: Enable for SAE encryption.
- **Guest Network**: Isolate with VLAN.
- **WIPS**: Wireless Intrusion Prevention.
- **Disable WPS**: Vulnerable to attacks.

### Scripts for Wireless Monitoring
#### Bash Script: Wi-Fi Scanner
```bash
#!/bin/bash
# wifi_scanner.sh: Scans for Wi-Fi networks
interface=$1
if [ -z "$interface" ]; then
  echo "Usage: $0 <interface>"
  exit 1
fi
iwlist $interface scan | grep -E 'ESSID|Channel|Signal'
```

#### Python Script: Signal Strength Checker
```python
import subprocess

def check_wifi_signal(interface='wlan0'):
    try:
        output = subprocess.run(['iwconfig', interface], capture_output=True, text=True)
        signal = output.stdout.split('Signal level=')[1].split(' ')[0] if 'Signal level' in output.stdout else 'N/A'
        print(f"Signal strength on {interface}: {signal} dBm")
    except:
        print("Error checking signal.")

check_wifi_signal()
```

## Internet Protocol Version 6 (IPv6)

### Overview
IPv6 addresses IP exhaustion with 128-bit addresses, offering vast space and built-in security. It replaces IPv4, supporting autoconfiguration and mobility.

**Key Features**:
- **Address Format**: Hexadecimal, e.g., 2001:db8::1.
- **Header Simplification**: No checksum, fixed size.
- **ICMPv6**: For ND, MLD.
- **Transition**: Dual-stack, tunneling (6to4).

### How IPv6 Works
1. **Addressing**: Global, link-local, unique local.
2. **Autoconfiguration**: SLAAC or DHCPv6.
3. **Neighbor Discovery**: Replaces ARP.
4. **Routing**: Similar to IPv4, with extensions.

### Common IPv6 Commands
- **Enable**: `ipv6 unicast-routing` (Cisco)
- **Assign Address**: `ipv6 address 2001:db8::1/64`
- **Show Neighbors**: `show ipv6 neighbors`
- **Ping**: `ping6 2001:db8::1`

### Troubleshooting IPv6
- **No Connectivity**: Check RA (`ipv6 nd ra suppress`), firewall.
- **Duplicate Addresses**: Monitor DAD.
- **Transition Issues**: Verify tunnels.
- **Common Issues**: Legacy devices without IPv6 support.

### Security Best Practices
- **IPsec Mandatory**: Built-in, enable AH/ESP.
- **Firewall**: Filter ICMPv6 carefully.
- **Privacy Extensions**: For temporary addresses.

### Scripts for IPv6 Monitoring
#### Bash Script: IPv6 Address Checker
```bash
#!/bin/bash
# ipv6_checker.sh: Lists IPv6 addresses
ip -6 addr show | grep inet6
```

#### Python Script: IPv6 Ping Tester
```python
import subprocess

def ping_ipv6(address='2001:4860:4860::8888'):
    try:
        output = subprocess.run(['ping6', '-c', '4', address], capture_output=True, text=True)
        print("IPv6 Ping Results:\n", output.stdout)
    except:
        print("Error pinging IPv6 address.")

ping_ipv6()
```