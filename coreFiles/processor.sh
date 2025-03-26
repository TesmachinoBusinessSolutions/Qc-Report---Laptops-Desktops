#!/bin/bash
# Function to get specific processor details
get_specific_processor_details() {
    lscpu | grep -E "Vendor ID:|Model name:|Architecture:|CPU MHz:|CPU op-mode\(s\):|Socket\(s\):|Virtualization:" | awk -F: '
    {
        printf "%-20s : %s\n", $1, $2
    }'
}

# Main script
echo "Processor Details:"
echo "-------------------"
get_specific_processor_details
