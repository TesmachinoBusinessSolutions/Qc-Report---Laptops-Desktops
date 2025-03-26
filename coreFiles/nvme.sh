#!/bin/bash

# Find NVMe or M.2 devices
devices=$(lsblk -d -n -o NAME,TYPE | grep -E 'disk' | awk '{print $1}' | grep -E '^nvme')

# Check if any devices were found
if [ -z "$devices" ]; then
    echo "No NVMe or M.2 devices found."
    exit 1
fi

# Loop through each device and get SMART data
for device in $devices; do
    echo "========================================"
    echo "SMART Data for /dev/$device"
    echo "========================================"
    model=$(sudo smartctl -i /dev/$device | grep "Model Number" | awk -F: '{print $2}' | xargs)
    serial=$(sudo smartctl -i /dev/$device | grep "Serial Number" | awk -F: '{print $2}' | xargs)
    capacity=$(lsblk -d -n -o SIZE /dev/$device | xargs)
    disk_type=$(lsblk -d -n -o TYPE /dev/$device | xargs)
    # Determine if the disk is NVMe or M.2
    if [[ $device == nvme* ]]; then
        disk_interface="NVMe"
    else
        disk_interface="M.2"
    fi
    temp_threshold_warning=$(sudo smartctl -a /dev/$device | grep -i "Warning  Comp. Temp. Threshold" | awk -F: '{print $2}' | xargs)
    temp_threshold_critical=$(sudo smartctl -a /dev/$device | grep -i "Critical Comp. Temp. Threshold" | awk -F: '{print $2}' | xargs)
    current_temp=$(sudo smartctl -a /dev/$device | grep -i "Temperature:" | awk -F: '{print $2}' | xargs)
    available_spare_threshold=$(sudo smartctl -a /dev/$device | grep -wi "Available Spare Threshold" | awk -F: '{print $2}' | xargs)
    percentage_used=$(sudo smartctl -a /dev/$device | grep -i "Percentage Used" | awk -F: '{print $2}' | xargs)
    available_spare=$(sudo smartctl -a /dev/$device | grep -wi "Available Spare:" | awk -F: '{print $2}' | xargs)
    data_units_read=$(sudo smartctl -a /dev/$device | grep -i "Data Units Read" | awk -F: '{print $2}' | xargs)
    data_units_written=$(sudo smartctl -a /dev/$device | grep -i "Data Units Written" | awk -F: '{print $2}' | xargs)
    power_cycles=$(sudo smartctl -a /dev/$device | grep -i "Power Cycles" | awk -F: '{print $2}' | xargs)
    power_on_hours=$(sudo smartctl -a /dev/$device | grep -i "Power On Hours" | awk -F: '{print $2}' | xargs)

    printf "%-30s: %s\n" "Model Number" "$model"
    printf "%-30s: %s\n" "Serial Number" "$serial"
    printf "%-30s: %s\n" "Capacity" "$capacity"
    printf "%-30s: %s\n" "Disk Type" "$disk_type"
    printf "%-30s: %s\n" "Disk Interface" "$disk_interface"
    printf "%-30s: %s\n" "Current Temperature" "$current_temp"
    printf "%-30s: %s\n" "Warning Temperature Threshold" "$temp_threshold_warning"
    printf "%-30s: %s\n" "Critical Temperature Threshold" "$temp_threshold_critical"
    printf "%-30s: %s\n" "Available Spare Threshold" "$available_spare_threshold"
    printf "%-30s: %s\n" "Percentage Used" "$percentage_used"
    printf "%-30s: %s\n" "Available Spare" "$available_spare"
    printf "%-30s: %s\n" "Data Units Read" "$data_units_read"
    printf "%-30s: %s\n" "Data Units Written" "$data_units_written"
    printf "%-30s: %s\n" "Power Cycles" "$power_cycles"
    printf "%-30s: %s\n" "Power On Hours" "$power_on_hours"
    echo "----------------------------------------"
done