#!/bin/bash

# Check if IP argument is provided
if [ -z "$1" ]; then
    echo "Error: No IP address provided" >> ~/Scripts/ip_change.log
    exit 1
fi

# Store the IP address
IP="$1"

# Display macOS notification
osascript -e "display notification \"New public IP address: $IP\" with title \"IP Address Update\""

# Log execution
echo "$(date): New IP: $IP" >> ~/Scripts/ip_change.log

exit 0