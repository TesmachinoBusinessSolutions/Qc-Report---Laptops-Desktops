#!/bin/bash

# Function to get SSD details
get_storage_info() {
    echo "Storage Device Information:"
    echo "==========================="

    # List all storage devices (exclude partitions like sda1, sda2, etc.)
    for device in /dev/usb*; do
        if [[ -b "$device" && ! "$device" =~ [0-9]$ ]]; then
            echo "Device: $device"
            
            # Model number
            model=$(sudo smartctl -i "$device" | grep "Model Number" | awk -F: '{print $2}' | xargs)
            echo "Model Number: ${model:-N/A}"

            # Serial number
            serial=$(sudo smartctl -i "$device" | grep "Serial Number" | awk -F: '{print $2}' | xargs)
            echo "Serial Number: ${serial:-N/A}"

            # Temperature
            temperature=$(sudo smartctl -A "$device" | awk '/Temperature/ {for (i=1; i<=NF; i++) if ($i ~ /[0-9]+/) {print $i; exit}}')
            echo "Temperature: ${temperature:-N/A}°C"
        
            # Warning temperature threshold
            warning_temp=$(sudo smartctl -A "$device" | awk '/Warning  Comp. Temp. Threshold:/ {print $NF}')
            echo "Warning Temperature Threshold: ${warning_temp:-N/A}°C"

            # Critical temperature threshold
            critical_temp=$(sudo smartctl -A "$device" | awk '/Critical Comp. Temp. Threshold:/ {for (i=1; i<=NF; i++) if ($i ~ /[0-9]+/) {print $i; exit}}')
            echo "Critical Temperature Threshold: ${critical_temp:-N/A}°C"

            # Data units read
            data_read=$(sudo smartctl -A "$device" | grep -i "Data Units Read" | awk -F: '{print $2}' | xargs)
            echo "Data Units Read: ${data_read:-N/A}"

            # Data units written
            data_written=$(sudo smartctl -A "$device" | grep -i "Data Units Written" | awk -F: '{print $2}' | xargs)
            echo "Data Units Written: ${data_written:-N/A}"

            # Power cycle count
            power_cycle=$(sudo smartctl -A "$device" | grep -i "Power Cycle Count" | awk -F: '{print $2}' | xargs)
            echo "Power Cycle Count: ${power_cycle:-N/A}"

            # Power-on hours
            power_on_hours=$(sudo smartctl -A "$device" | grep -i "Power On Hours" | awk -F: '{print $2}' | xargs)
            echo "Power On Hours: ${power_on_hours:-N/A}"

            # Unsafe shutdowns
            unsafe_shutdowns=$(sudo smartctl -A "$device" | grep -i "Unsafe Shutdowns" | awk -F: '{print $2}' | xargs)
            echo "Unsafe Shutdowns: ${unsafe_shutdowns:-N/A}"

            echo "---------------------------"
        fi
    done
}

# Check if smartctl is installed
if ! command -v smartctl &> /dev/null; then
    echo "Error: smartctl is not installed. Please install it using your package manager."
    exit 1
fi

# Run the function
get_storage_info
