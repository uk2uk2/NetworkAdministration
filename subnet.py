import math

def calculate_subnet(network, cidr):
    # Validate CIDR
    if not 0 <= cidr <= 32:
        return "Invalid CIDR. Must be between 0 and 32."
    
    # Parse network address
    try:
        octets = network.split('.')
        if len(octets) != 4 or not all(0 <= int(o) <= 255 for o in octets):
            return "Invalid IP address."
    except:
        return "Invalid IP address format."
    
    # Calculate subnet details
    subnet_mask = (0xffffffff << (32 - cidr)) & 0xffffffff
    mask_octets = [(subnet_mask >> (24 - 8 * i)) & 0xff for i in range(4)]
    wildcard = [(0xff ^ m) for m in mask_octets]
    total_hosts = 2 ** (32 - cidr)
    usable_hosts = total_hosts - 2 if total_hosts > 2 else total_hosts
    
    # Network and broadcast addresses
    network_int = sum(int(octets[i]) << (24 - 8 * i) for i in range(4))
    network_addr = network_int & subnet_mask
    broadcast_addr = network_int | (2 ** (32 - cidr) - 1)
    
    # Convert to dotted decimal
    network_octets = [(network_addr >> (24 - 8 * i)) & 0xff for i in range(4)]
    broadcast_octets = [(broadcast_addr >> (24 - 8 * i)) & 0xff for i in range(4)]
    
    # First and last usable IPs
    first_usable = network_addr + 1 if usable_hosts > 0 else network_addr
    last_usable = broadcast_addr - 1 if usable_hosts > 0 else broadcast_addr
    first_usable_octets = [(first_usable >> (24 - 8 * i)) & 0xff for i in range(4)]
    last_usable_octets = [(last_usable >> (24 - 8 * i)) & 0xff for i in range(4)]
    
    # Output results
    result = f"""
Subnet Calculator Results for {network}/{cidr}:
Subnet Mask: {'.'.join(map(str, mask_octets))}
Wildcard Mask: {'.'.join(map(str, wildcard))}
Total Hosts: {total_hosts}
Usable Hosts: {usable_hosts}
Network Address: {'.'.join(map(str, network_octets))}
Broadcast Address: {'.'.join(map(str, broadcast_octets))}
First Usable IP: {'.'.join(map(str, first_usable_octets))}
Last Usable IP: {'.'.join(map(str, last_usable_octets))}
"""
    return result

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python subnet_calculator.py <network> <cidr>")
        print("Example: python subnet_calculator.py 192.168.1.0 24")
        sys.exit(1)
    network, cidr = sys.argv[1], int(sys.argv[2])
    print(calculate_subnet(network, cidr))
