#!/bin/bash
# certificate_test.sh: Tests SSL/TLS certificates for network admin tasks
# Usage: ./certificate_test.sh <hostname> [port]
# Example: ./certificate_test.sh example.com 443

hostname=$1
port=${2:-443}
logfile="/var/log/cert_test_$(date +%F_%H-%M-%S).log"

echo "Certificate Test Script - Started at $(date)" | tee -a $logfile

# Check if hostname is provided
if [ -z "$hostname" ]; then
  echo "Error: Hostname required. Usage: $0 <hostname> [port]" | tee -a $logfile
  exit 1
fi

# Test 1: Verify certificate expiry
echo -e "\nChecking certificate expiry for $hostname:$port..." | tee -a $logfile
if ! command -v openssl >/dev/null 2>&1; then
  echo "Error: OpenSSL not installed" | tee -a $logfile
  exit 1
fi

cert_info=$(openssl s_client -connect "$hostname:$port" -servername "$hostname" </dev/null 2>/dev/null | openssl x509 -noout -dates)
if [ $? -eq 0 ]; then
  not_after=$(echo "$cert_info" | grep notAfter | cut -d= -f2)
  expiry_date=$(date -d "$not_after" +%s)
  current_date=$(date +%s)
  days_left=$(( (expiry_date - current_date) / 86400 ))
  echo "Certificate expires on $not_after ($days_left days left)" | tee -a $logfile
  if [ $days_left -lt 30 ]; then
    echo "Warning: Certificate expires in less than 30 days!" | tee -a $logfile
  fi
else
  echo "Failed to retrieve certificate" | tee -a $logfile
fi

# Test 2: Check certificate chain
echo -e "\nChecking certificate chain for $hostname:$port..." | tee -a $logfile
chain_info=$(openssl s_client -connect "$hostname:$port" -servername "$hostname" -showcerts </dev/null 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "$chain_info" | grep -i "issuer" | tee -a $logfile
  if echo "$chain_info" | grep -q "verify error"; then
    echo "Warning: Certificate chain verification failed" | tee -a $logfile
  else
    echo "Certificate chain verification passed" | tee -a $logfile
  fi
else
  echo "Failed to retrieve certificate chain" | tee -a $logfile
fi

# Test 3: Verify supported protocols
echo -e "\nChecking supported TLS protocols for $hostname:$port..." | tee -a $logfile
protocols=("ssl3" "tls1" "tls1_1" "tls1_2" "tls1_3")
for proto in "${protocols[@]}"; do
  if openssl s_client -connect "$hostname:$port" -"$proto" </dev/null >/dev/null 2>&1; then
    echo "$proto supported" | tee -a $logfile
  else
    echo "$proto not supported" | tee -a $logfile
  fi
done

# Test 4: Check for common issues (e.g., hostname mismatch)
echo -e "\nChecking for common certificate issues..." | tee -a $logfile
if openssl s_client -connect "$hostname:$port" -servername "$hostname" </dev/null 2>&1 | grep -q "Hostname mismatch"; then
  echo "Warning: Hostname mismatch detected" | tee -a $logfile
else
  echo "No hostname mismatch detected" | tee -a $logfile
fi

echo -e "\nCertificate Test Completed at $(date)" | tee -a $logfile
echo "Results logged to $logfile"
