#!/bin/bash

# Define a function to print verbose output if the -v flag is set
verbose_echo() {
    if [ "$VERBOSE" = true ]; then
        echo "$@"
    fi
}

# Parse command line arguments
while getopts "vh" opt; do
    case ${opt} in
        v ) VERBOSE=true;;
        h ) echo "Usage: $0 [-v] [-h] <last-three-octets>"
            echo "  -v  : verbose output"
            echo "  -h  : print help message"
            echo "  <last-three-octets> : last three octets of the Bluetooth device address (in format XX:XX:XX)"
            exit 0;;
        * ) echo "Usage: $0 [-v] <last-three-octets>"; exit 1;;
    esac
done
shift $((OPTIND -1))

# Get the last three octets from the command line argument
if [ -z "$1" ]; then
    echo "Usage: $0 [-v] <last-three-octets>"
    exit 1
else
    device_address="$1"
fi

# Check if the user input is valid
if [[ ! $device_address =~ ^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$ ]]; then
    echo "Invalid Bluetooth device address. Please enter the last 3 octets of the Bluetooth device address in format XX:XX:XX."
    exit 1
fi

# Iterate through all possible values of the third octet
for i in $(seq 0 255); do
    # Construct the Bluetooth device address
    address="00:00:"$(printf "%02X" $i)":$device_address"
    
    # Try to ping the device using sudo
    sudo l2ping -c 1 $address > /dev/null 2>&1
    
    # Check the result of the ping
    if [ $? -eq 0 ]; then
        echo "Device found: $address"
        exit 0
    fi
    
    # Print verbose output if the -v flag is set
    verbose_echo "Tried address: $address"
done

echo "Device not found"
exit 1
