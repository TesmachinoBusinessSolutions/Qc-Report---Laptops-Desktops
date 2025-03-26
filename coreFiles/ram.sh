#!/bin/bash

# Function to get RAM slot count
get_ram_slots() {
    sudo dmidecode -t memory | grep -i "Number Of Devices" | awk '{print $4}'
}

# Function to get total RAM size
get_total_ram() {
    free -h | awk '/Mem:/ {print $2}'
}

# Function to get RAM details for each slot, hiding empty slots
get_ram_details() {
    local slot_count=$(get_ram_slots)
    if [[ -z "$slot_count" || ! "$slot_count" =~ ^[0-9]+$ ]]; then
        echo "Error: Could not determine RAM slot count."
        return 1
    fi

    for ((i=0; i<slot_count; i++)); do
        local slot_info=$(sudo dmidecode -t memory | awk -v slot="$i" '
        /Memory Device/ {
            slot_num++
        }
        slot_num == slot + 1 && /Size:|Type:|Manufacturer:|Speed:|Serial Number:/ {
            print
        }
        ')

        if [[ -n "$slot_info" && "$slot_info" != *"No Module Installed"* ]]; then
            echo "========================="
            echo "       Slot $((i+1))       "
            echo "========================="
            echo "$slot_info" | sed 's/^/  /'
        fi
    done
}

# Main script
echo "========================================="
echo "         RAM Information Summary         "
echo "========================================="
echo "Number of RAM Slots: $(get_ram_slots)"
echo "Total RAM Capacity (Installed): $(get_total_ram)"
echo
echo "RAM Details:"
get_ram_details
echo "========================================="