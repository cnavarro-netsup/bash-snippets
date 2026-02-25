#!/bin/bash

# Function to validate a public IPv4 address
# Usage: is_public_ipv4 <IP_ADDRESS>
# Returns 0 if valid and public, 1 otherwise
# Date: 2026-02-25
# Autor: CPN + gemini (Antigravity)

is_public_ipv4() {
    local ip="$1"
    
    # Check if exactly 4 octets exist and are only digits
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    
    # Split IP into array of octets
    IFS='.' read -r -a octets <<< "$ip"
    
    # Check if each octet is between 0 and 255
    for octet in "${octets[@]}"; do
        if (( octet > 255 )); then
            return 1
        fi
        # Check for leading zeros (except for actual 0)
        if [[ "$octet" =~ ^0[0-9]+$ ]]; then
            return 1
        fi
    done
    
    # Additional checks for public IP
    # First octet can't be 0 (current network) or 255 (broadcast)
    if (( octets[0] == 0 || octets[0] == 255 )); then
        return 1
    fi

    # Check for private ranges (RFC 1918)
    # 10.0.0.0/8
    if (( octets[0] == 10 )); then
        return 1
    fi
    
    # 172.16.0.0/12 (172.16.0.0 to 172.31.255.255)
    if (( octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31 )); then
        return 1
    fi
    
    # 192.168.0.0/16
    if (( octets[0] == 192 && octets[1] == 168 )); then
        return 1
    fi

    # Check for Loopback (127.0.0.0/8)
    if (( octets[0] == 127 )); then
        return 1
    fi

    # Check for Link-Local (169.254.0.0/16)
    if (( octets[0] == 169 && octets[1] == 254 )); then
        return 1
    fi
    
    # Check for Carrier-grade NAT (100.64.0.0/10)
    if (( octets[0] == 100 && octets[1] >= 64 && octets[1] <= 127 )); then
        return 1
    fi

    # Check for TEST-NET-1, 2, 3 (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)
    if [[ "$ip" == 192.0.2.* ]] || [[ "$ip" == 198.51.100.* ]] || [[ "$ip" == 203.0.113.* ]]; then
        return 1
    fi
    
    # Check for Multicast (224.0.0.0/4 - 224 to 239)
    if (( octets[0] >= 224 && octets[0] <= 239 )); then
        return 1
    fi

    # Check for Reserved (240.0.0.0/4 - 240 to 255)
    if (( octets[0] >= 240 && octets[0] <= 255 )); then
        return 1
    fi

    # If all checks pass, it's a valid public IPv4
    return 0
}
