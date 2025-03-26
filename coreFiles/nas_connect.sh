#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi
# Open a new terminal and ensure the script is run as root

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

mount -t cifs -o username=$NAS_USER,password=$NAS_PASSWORD,vers=3.0,uid=$(id -u),gid=$(id -g),sec=ntlm //$NAS_IP/$NAS_PATH $TEMP_MOUNT_POINT
TEMP_MOUNT_POINT=$(mktemp -d)
# Mount the NAS share
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

# Unmount the NAS share
echo "Unmounting NAS share..."
umount $TEMP_MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "Failed to unmount NAS share. Please unmount manually."
    exit 1
fi

# Clean up
rmdir $TEMP_MOUNT_POINT
echo "Done."
