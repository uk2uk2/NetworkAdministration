#!/bin/bash
# dhcp_test.sh: Tests DHCP server functionality for network admin tasks
# Usage: ./dhcp_test.sh [interface]
# Example: ./dhcp_test.sh eth0

interface=${1:-eth0}
logfile="/var/log/dhcp_test_$(date +%F_%H-%M-%S).log"

echo "DHCP Test Script - Started at $(date)" | tee -a $logfile

# Check if interface exists
if ! ip link show $interface > /dev/null 2>&1; then
  echo "Error: Interface $interface not found" | tee -a $logfile
  exit 1
fi

# Test 1: Release and renew DHCP lease
echo "Testing DHCP lease renewal..." | tee -a $logfile
if dhclient -r $interface && dhclient $interface; then
  echo "DHCP lease renewal successful" | tee -a $logfile
  ip addr show $interface | grep inet | tee -a $logfile
else
  echo "DHCP lease renewal failed" | tee -a $logfile
fi

# Test 2: Verify DHCP server response time
echo -e "\nTesting DHCP server response time..." | tee -a $logfile
start_time=$(date +%s)
if dhclient -r $interface && dhclient -t 5 $interface > /dev/null 2>&1; then
  end_time=$(date +%s)
  response_time=$((end_time - start_time))
  echo "DHCP server responded in $response_time seconds" | tee -a $logfile
else
  echo "DHCP server failed to respond within 5 seconds" | tee -a $logfile
fi

# Test 3: Check for multiple DHCP servers (rogue DHCP detection)
echo -e "\nChecking for multiple DHCP servers..." | tee -a $logfile
if command -v dhcp_probe > /dev/null 2>&1; then
  dhcp_probe -i $interface | tee -a $logfile
else
  echo "dhcp_probe not installed; skipping rogue DHCP check" | tee -a $logfile
  echo "Install dhcp_probe for rogue DHCP detection" | tee -a $logfile
fi

# Test 4: Verify DNS from DHCP
echo -e "\nTesting DNS resolution from DHCP..." | tee -a $logfile
dns_servers=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
for dns in $dns_servers; do
  if nslookup google.com $dns > /dev/null 2>&1; then
    echo "DNS resolution via $dns successful" | tee -a $logfile
  else
    echo "DNS resolution via $dns failed" | tee -a $logfile
  fi
done

echo -e "\nDHCP Test Completed at $(date)" | tee -a $logfile
echo "Results logged to $logfile"
