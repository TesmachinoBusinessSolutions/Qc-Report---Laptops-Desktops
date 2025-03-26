#!/bin/bash

# Improved script to gather SMART data for HDDs/SSDs (excluding USB)

# Function to get SMART data with error handling
get_smart_data() {
    local device="$1"
    local attribute="$2"
    local regex="$3"

    local value=$(sudo smartctl -a "/dev/$device" | grep -i "$regex" | awk -F: '{print $2}' | xargs)

    if [ -z "$value" ]; then
        echo "N/A" # Indicate data not available
    else
        echo "$value"
    fi
}

# Function to get basic device info with error handling
get_device_info() {
    local device="$1"
    local info_type="$2"

    local value=$(sudo smartctl -i "/dev/$device" | grep "$info_type" | awk -F: '{print $2}' | xargs)

    if [ -z "$value" ]; then
        echo "N/A"
    else
        echo "$value"
    fi
}

# Function to get lsblk info with error handling
get_lsblk_info() {
    local device="$1"
    local info_type="$2"

    local value=$(lsblk -d -n -o "$info_type" "/dev/$device" | xargs)

    if [ -z "$value" ]; then
        echo "N/A"
    else
        echo "$value"
    fi
}

# Find HDD / SSD excluding USB drives
devices=$(lsblk -d -n -o NAME,TYPE,TRAN | grep -E 'disk' | grep -v 'usb' | awk '{print $1}')

# Check if any devices were found
if [ -z "$devices" ]; then
    echo "No HDD/SSD devices found."
    exit 1
fi

# Loop through each device and get SMART data
for device in $devices; do
    echo "========================================"
    echo "SMART Data for /dev/$device"
    echo "========================================"

    model=$(get_device_info "$device" "Device Model")
    serial=$(get_device_info "$device" "Serial Number")
    capacity=$(get_lsblk_info "$device" "SIZE")
    disk_type=$(get_lsblk_info "$device" "TYPE")
    form_factor=$(get_device_info "$device" "Form Factor")
    user_capacity=$(get_device_info "$device" "User Capacity")
    sata_version=$(get_device_info "$device" "SATA Version")

    # Determine if the disk is SSD or HDD
    rotational=$(cat "/sys/block/$device/queue/rotational" 2>/dev/null) #added error suppression
    if [[ -n "$rotational" && "$rotational" -eq 0 ]]; then
        disk_interface="SSD"
    else
        disk_interface="HDD"
    fi

    printf "%-30s: %s\n" "Model Number" "$model"
    printf "%-30s: %s\n" "Serial Number" "$serial"
    printf "%-30s: %s\n" "Capacity" "$capacity"
    printf "%-30s: %s\n" "Disk Type" "$disk_type"
    printf "%-30s: %s\n" "Form Factor" "$form_factor"
    printf "%-30s: %s\n" "User Capacity" "$user_capacity"
    printf "%-30s: %s\n" "SATA Version" "$sata_version"
    printf "%-30s: %s\n" "Disk Interface" "$disk_interface"
    echo "----------------------------------------"
done


# //health of the HDD