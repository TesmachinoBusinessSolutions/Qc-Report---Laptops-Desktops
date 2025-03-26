#!/bin/bash

# Script to display comprehensive system details
# # Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl not found. Installing curl..."
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update && sudo apt-get install -y curl
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y curl
    else
        echo "Package manager not supported. Please install curl manually."
        exit 1
    fi
fi


echo "==================== Checking Sudo user... ===================="
# Check if the script is running with sudo, if not, re-run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script is not running as root. Re-running with sudo..."
    exec sudo bash "$0" "$@"
    exit 1
fi

echo "==================== Check if internet is working ===================="
# Check if the internet is working
if curl -s --head http://www.google.com | grep "200 OK" > /dev/null; then
    echo "Internet connection is active."
    else
    echo "No active internet connection. Please check your network."
fi

echo "==================== Fetching current time from the internet... ===================="
# Fetch and display current time from the internet
echo "Fetching current time from the internet..."
# Fetch current time
    current_time=$(cat </dev/tcp/time.nist.gov/13)
    if [ -n "$current_time" ]; then
        echo "Current Internet Time: $current_time"
    else
        echo "Unable to fetch current time from the internet."
    fi

echo "==================== System Details ===================="

# Function to get system serial number
get_serial_number() {
  sudo dmidecode -s system-serial-number
}

# Function to get system manufacturer
get_manufacturer() {
  sudo dmidecode -s system-manufacturer
}

# Function to get system product name (brand/model)
get_product_name() {
  sudo dmidecode -s system-product-name
}


# Main script
echo "System Serial Number: $(get_serial_number)"
echo "System Manufacturer: $(get_manufacturer)"
echo "System Product Name: $(get_product_name)"




# CPU Information
echo "==================== CPU Information ===================="
echo "CPU Model: $(grep 'model name' /proc/cpuinfo | uniq | awk -F': ' '{print $2}')"
echo "CPU Cores: $(grep -c '^processor' /proc/cpuinfo)"

echo "==================== Memory Information ===================="
# Number of RAM slots
echo "Number of RAM Slots: $( dmidecode -t memory | grep -c '^Memory Device$')"
echo "Number of Installed RAM Slots: $( dmidecode -t memory | grep -c -Po '^\tPart Number: (?!\[Empty\])')"
echo "Maximum Capacity: $(dmidecode -t memory | awk -F: '/Maximum Capacity:/ {print $2}')"

# Memory Information
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
# Detailed RAM Slot Information
echo "==================== RAM Slot Details ===================="
echo "==================== Installed Memory Details ===================="
# dmidecode -t memory | awk -F: '
# /Form Factor/ {form=$2}
# /Locator/ {slot=$2}
# /Size/ {size=$2}
# /Manufacturer/ {manufacturer=$2}
# /Speed/ {speed=$2}
# /Memory Technology/ {memtech=$2}
# /Type/ {type=$2}
# /Serial Number/ {serial=$2}
# END {
#     if (size !~ /No Module Installed/) {
#         printf "Slot: %s\nSize: %s\nManufacturer: %s\nSpeed: %s\nSerial Number: %s\nForm Factor: %s\nMemory Technology: %s\nType: %s\n\n", slot, size, manufacturer, speed, serial, form, memtech, type
#     }
# }'

#!/bin/bash






# Network Information
echo "Network Interfaces:"
ip -o -4 addr show | awk '{print $2, $4}'

# Uptime
echo "System Uptime: $(uptime -p)"

# Logged-in Users
echo "Logged-in Users:"
who

# Last Boot Time
echo "Last Boot Time: $(who -b | awk '{print $3, $4}')"

# Running Processes
echo "Number of Running Processes: $(ps aux | wc -l)"

echo "========================================================"


#   Type   Information
#        --------------------------------------------
#           0   BIOS
#           1   System
#           2   Baseboard
#           3   Chassis
#           4   Processor
#           5   Memory Controller
#           6   Memory Module
#           7   Cache
#           8   Port Connector
#           9   System Slots
#          10   On Board Devices
#          11   OEM Strings
#          12   System Configuration Options
#          13   BIOS Language
#          14   Group Associations
#          15   System Event Log
#          16   Physical Memory Array
#          17   Memory Device
#          18   32-bit Memory Error
#          19   Memory Array Mapped Address
#          20   Memory Device Mapped Address
#          21   Built-in Pointing Device
#          22   Portable Battery
#          23   System Reset
#          24   Hardware Security
#          25   System Power Controls
#          26   Voltage Probe
#          27   Cooling Device
#          28   Temperature Probe
#          29   Electrical Current Probe
#          30   Out-of-band Remote Access31   Boot Integrity Services
#          32   System Boot
#          33   64-bit Memory Error
#          34   Management Device
#          35   Management Device Component
#          36   Management Device Threshold Data
#          37   Memory Channel
#          38   IPMI Device
#          39   Power Supply
#          40   Additional Information
#          41   Onboard Devices Extended Information
#          42   Management Controller Host Interface