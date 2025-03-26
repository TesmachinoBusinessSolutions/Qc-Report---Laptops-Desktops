#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exec sudo bash "$0" "$@"
fi

set -x # Enable debugging
# NAS connection details
NAS_IP="192.168.0.38"
NAS_USER="exxtendit-nas"
NAS_PASSWORD="1234"
NAS_PATH="ExxtendIT_Nas_Share/Scripts/coreFiles/"
QC_FILE="exxtendit_qc.sh"

# Check if the NAS IP is reachable
if ! ping -c 1 -W 1 $NAS_IP > /dev/null 2>&1; then
    echo "Error: NAS IP $NAS_IP is not reachable. Please check the network connection."
    exit 1
fi

# Mount the NAS share
TEMP_MOUNT_POINT=$(mktemp -d)
echo "Mounting NAS share..."
mount -t cifs -o username=$NAS_USER,password=$NAS_PASSWORD,vers=3.0,uid=$(id -u),gid=$(id -g) //$NAS_IP/$NAS_PATH $TEMP_MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to mount NAS share. Please check permissions or credentials."
    rmdir $TEMP_MOUNT_POINT
    exit 1
fi

# List files in the mount point
echo "Listing all files under the path:"
ls -l "$TEMP_MOUNT_POINT"

# Check if the QC file exists
if [ -f "$TEMP_MOUNT_POINT/$QC_FILE" ]; then
    echo "QC file found at mount point: $TEMP_MOUNT_POINT/$NAS_PATH"
    echo "Running the QC file with sudo..."
    sudo bash "$TEMP_MOUNT_POINT/$QC_FILE"
else
    echo "Error: QC file not found in the NAS share. Please verify the file exists."
    umount $TEMP_MOUNT_POINT
    rmdir $TEMP_MOUNT_POINT
    exit 1
fi

# Ensure the NAS share is unmounted after the script has completed
echo "Unmounting NAS share..."
umount $TEMP_MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to unmount NAS share. Please unmount manually."
    exit 1
fi

# Clean up
rmdir $TEMP_MOUNT_POINT
echo "Done."

# Source the prep.sh script for login
PREP_SCRIPT="$TEMP_MOUNT_POINT/prep.sh"
if [ -f "$PREP_SCRIPT" ]; then
    echo "Executing prep.sh for login..."
    source "$PREP_SCRIPT"
else
    echo "Error: prep.sh not found in the NAS share. Please verify the file exists."
    umount $TEMP_MOUNT_POINT
    rmdir $TEMP_MOUNT_POINT
    exit 1
fi

read -p "Enter the QC person's name: " qc_name
echo "Welcome, $qc_name!"
# Menu for system information
while true; do
    echo "Select an option to display system information:"
    echo "1) System Information"
    echo "2) RAM Information"
    echo "3) CPU Information"
    echo "4) Storage Information"
    echo "5) Battery Information"
    echo "6) Run All in Sequence"
    echo "7) Save All to File (System Serial Number)"
    echo "8) Exit"
    read -p "Enter your choice [1-8]: " choice

        case $choice in
            1)
                echo "--- System Information ---"
                bash "$TEMP_MOUNT_POINT/systemdetails.sh"
                ;;
            2)
                echo "--- RAM Information ---"
                bash "$TEMP_MOUNT_POINT/ram.sh"
                ;;
            3)
                echo "--- CPU Information ---"
                bash "$TEMP_MOUNT_POINT/processor.sh"
                ;;
            4)
                echo "--- Storage Information ---"
                bash "$TEMP_MOUNT_POINT/nvme.sh"
                ;;
            5)
                echo "--- Battery Information ---"
                bash "$TEMP_MOUNT_POINT/battery.sh"
                ;;
            6)
                echo "Running all scripts in sequence..."
                bash "$TEMP_MOUNT_POINT/systemdetails.sh"
                bash "$TEMP_MOUNT_POINT/ram.sh"
                bash "$TEMP_MOUNT_POINT/processor.sh"
                bash "$TEMP_MOUNT_POINT/nvme.sh"
                bash "$TEMP_MOUNT_POINT/battery.sh"
                ;;
            7)
                serial_number=$(sudo dmidecode -s system-serial-number)
                timestamp=$(date +"%Y%m%d_%H%M%S")
                report_folder="../report"
                mkdir -p "$report_folder"
                output_file="${report_folder}/${serial_number}_${timestamp}.txt"

                echo "Saving all information to $output_file..."
                {
                    echo "QC Person: $qc_name"
                    echo "Generated On: $(date)"
                    bash "$TEMP_MOUNT_POINT/systemdetails.sh"
                    bash "$TEMP_MOUNT_POINT/ram.sh"
                    bash "$TEMP_MOUNT_POINT/processor.sh"
                    bash "$TEMP_MOUNT_POINT/nvme.sh"
                    bash "$TEMP_MOUNT_POINT/battery.sh"
                } > "$output_file"
                echo "Information saved to $output_file."
                ;;
            8)
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid choice. Please select a valid option."
                ;;
        esac
    done
