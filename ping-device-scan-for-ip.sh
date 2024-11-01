#!/bin/bash

# Default values
PING_COUNT=3
PING_TIMEOUT=2
TARGET_IP=""

# Function to print usage
print_usage() {
    echo "Usage: $0 -i target_ip [-t timeout] [-c ping_count]"
    echo "Options:"
    echo "  -i IP    Target IP address to scan (required)"
    echo "  -t SEC   Ping timeout in seconds (default: 2)"
    echo "  -c NUM   Number of pings per interface (default: 3)"
    echo "  -h       Show this help message"
    exit 1
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    for octet in $(echo $ip | tr '.' ' '); do
        if [[ $octet -lt 0 || $octet -gt 255 ]]; then
            return 1
        fi
    done
    return 0
}

# Parse command line arguments
while getopts "i:t:c:h" opt; do
    case $opt in
        i)
            TARGET_IP="$OPTARG"
            if ! validate_ip "$TARGET_IP"; then
                echo "Error: Invalid IP address format"
                exit 1
            fi
            ;;
        t)
            if [[ ! $OPTARG =~ ^[0-9\.]+$ ]]; then
                echo "Error: Timeout must be a positive number"
                exit 1
            fi
            PING_TIMEOUT=$OPTARG
            ;;
        c)
            if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
                echo "Error: Ping count must be a positive number"
                exit 1
            fi
            PING_COUNT=$OPTARG
            ;;
        h)
            print_usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            print_usage
            ;;
    esac
done

# Check if target IP was provided
if [ -z "$TARGET_IP" ]; then
    echo "Error: Target IP address is required"
    print_usage
fi

# Store results in a temporary file
temp_file=$(mktemp)

echo "Testing connectivity to $TARGET_IP across interfaces with active routes..."
echo "Parameters: timeout=$PING_TIMEOUT seconds, count=$PING_COUNT pings"

# Get interfaces that have routes (excluding lo)
interfaces=$(ip route | grep -v 'lo' | awk '{
    for(i=1; i<=NF; i++) {
        if($i == "dev" && $(i+1) != "") {
            print $(i+1)
            break
        }
    }
}' | sort | uniq)

# Initialize variables for tracking best result
best_latency=999999
best_interface=""
best_gateway=""

for interface in $interfaces; do
    echo "Testing interface $interface..."

    # Get the gateway for this interface (if any)
    gateway=$(ip route show dev $interface | awk '/default/ {print $3}')

    # Try pings and get average
    ping_result=$(ping -W $PING_TIMEOUT -c $PING_COUNT -I $interface $TARGET_IP 2>/dev/null | tail -1 | awk -F '/' '{print $5}')

    if [ ! -z "$ping_result" ]; then
        echo "$interface: $ping_result ms (gateway: ${gateway:-direct})" >> $temp_file

        # Compare with best result
        if (( $(echo "$ping_result < $best_latency" | bc -l) )); then
            best_latency=$ping_result
            best_interface=$interface
            best_gateway=$gateway
        fi
    fi
done

echo -e "\nResults:"
if [ -s "$temp_file" ]; then
    cat "$temp_file"
    echo -e "\nBest performing interface: $best_interface with latency: $best_latency ms"

    # Generate the appropriate route add command
    if [ ! -z "$best_gateway" ]; then
        echo -e "\nStatic route command:"
        echo "ip route add $TARGET_IP via $best_gateway dev $best_interface"
    else
        echo -e "\nStatic route command:"
        echo "ip route add $TARGET_IP dev $best_interface"
    fi
else
    echo "No interfaces could reach $TARGET_IP"
fi

# Cleanup
rm $temp_file
