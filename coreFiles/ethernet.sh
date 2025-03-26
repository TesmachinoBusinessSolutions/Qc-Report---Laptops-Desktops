#!/bin/bash

# Check if an Ethernet cable is connected and working (live monitoring)

# Get the network interface name (e.g., eth0, enp0s3)
INTERFACE=$(ip link | grep -E '^[0-9]+: ' | grep -oE '^[0-9]+: [^:]*' | awk '{print $2}' | grep -E '^e')

if [ -z "$INTERFACE" ]; then
    echo -e "\e[31m[ERROR]\e[0m No Ethernet interface found."
    exit 1
fi

echo -e "\e[34m[INFO]\e[0m Monitoring Ethernet status on interface: \e[33m$INTERFACE\e[0m"
echo -e "\e[34m[INFO]\e[0m Press Ctrl+C to stop or Ctrl+\\ to skip the test."
echo "---------------------------------------------"

# Flag to control the loop
SKIP_TEST=false

# Function to handle skipping the test
skip_test() {
    echo -e "\n\e[33m[INFO]\e[0m Skipping the test. Returning to the main script..."
    SKIP_TEST=true
}

# Trap Ctrl+\ (SIGQUIT) to skip the test
trap skip_test SIGQUIT

# Timeout counter
TIMEOUT=10
SECONDS_ELAPSED=0

# Infinite loop to monitor the status
while true; do
    if [ "$SKIP_TEST" = true ] || [ "$SECONDS_ELAPSED" -ge "$TIMEOUT" ]; then
        break
    fi

    # Check the carrier status of the Ethernet interface
    CARRIER_STATUS=$(cat /sys/class/net/$INTERFACE/carrier 2>/dev/null)

    if [ "$CARRIER_STATUS" == "1" ]; then
        # Check if the interface has an IP address
        IP_ADDRESS=$(ip addr show $INTERFACE | grep 'inet ' | awk '{print $2}')

        if [ -n "$IP_ADDRESS" ]; then
            echo -e "\e[32m[$(date)]\e[0m Ethernet connection is working. \e[36mIP Address: $IP_ADDRESS\e[0m"
        else
            echo -e "\e[33m[$(date)]\e[0m Ethernet cable is connected, but \e[31mno IP address\e[0m is assigned."
        fi
    else
        echo -e "\e[31m[$(date)]\e[0m Ethernet cable is \e[31mnot connected\e[0m to \e[33m$INTERFACE\e[0m."
    fi

    # Wait for 5 seconds before checking again
    sleep 5
    SECONDS_ELAPSED=$((SECONDS_ELAPSED + 5))
done

if [ "$SECONDS_ELAPSED" -ge "$TIMEOUT" ]; then
    echo -e "\e[33m[INFO]\e[0m Auto-skipping the test after $TIMEOUT seconds."
fi

echo -e "\e[34m[INFO]\e[0m Test skipped. Exiting monitoring loop."