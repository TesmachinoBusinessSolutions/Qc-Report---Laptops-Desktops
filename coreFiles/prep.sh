#!/bin/bash

# Ensure the script is running with sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges. Re-running with sudo..."
    exec sudo bash "$0" "$@"
fi

echo "==================== Checking Internet Connectivity ===================="
# Verify internet connection
if sudo curl -s --head http://www.google.com | grep "200 OK" > /dev/null; then
    echo "Internet connection is active."
else
    echo "No active internet connection detected. Please check your network settings."
    exit 1
fi

echo "==================== Fetching Current Time ===================="
# Retrieve and display the current time from the internet
echo "Attempting to fetch the current time from the internet..."
current_time=$(sudo cat </dev/tcp/time.nist.gov/13 2>/dev/null)
if [ -n "$current_time" ]; then
    echo "Current Internet Time: $current_time"
else
    echo "Failed to fetch the current time from the internet."
fi

echo "==================== System Details ===================="
# Placeholder for system details (expand as needed)

echo "==================== Verifying Dependencies ===================="
# Ensure `smartctl` is installed
if ! command -v smartctl &> /dev/null; then
    echo "smartctl is not installed. Installing it now..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y smartmontools
    elif command -v yum &> /dev/null; then
        yum install -y smartmontools
    else
        echo "Unsupported package manager. Please install smartctl manually."
        exit 1
    fi
else
    echo "smartctl is already installed."
fi

# Ensure `curl` is installed
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing it now..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    else
        echo "Unsupported package manager. Please install curl manually."
        exit 1
    fi
else
    echo "curl is already installed."
fi

echo "==================== All Dependencies Verified ===================="
