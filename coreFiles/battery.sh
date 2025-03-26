#!/bin/bash

# Function to get battery details including health percentage
get_battery_details() {
    battery_devices=$(upower -e | grep battery)

    if [[ -n "$battery_devices" ]]; then
        for battery_device in $battery_devices; do
            echo ""
            echo "-----------------------------------------"
            echo "Battery: $(basename $battery_device)"
            echo "-----------------------------------------"
            designed_capacity=$(upower -i "$battery_device" | grep energy-full-design: | awk -F': ' '{print $2}' | awk '{print $1}')
            existing_capacity=$(upower -i "$battery_device" | grep energy-full: | awk -F': ' '{print $2}' | awk '{print $1}')
            voltage=$(upower -i "$battery_device" | grep voltage: | awk -F': ' '{print $2}')

            if [[ -n "$designed_capacity" && -n "$existing_capacity" ]]; then
                health_percentage=$(echo "scale=2; ($existing_capacity * 100) / $designed_capacity" | bc)
                echo "  Battery Health:       $health_percentage%"
                echo "  Designed Capacity:    $designed_capacity Wh"
                echo "  Existing Capacity:    $existing_capacity Wh"
                echo "  Voltage:              $voltage V"
            else
                echo "  Could not retrieve battery capacity information."
            fi
        done
        echo ""
        echo "========================================="
    else
        echo "No battery devices found."
        return 1
    fi
}

# Main script
get_battery_details