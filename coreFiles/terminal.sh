#!/bin/bash
gksu gnome-terminal -- bash -c "sudo bash '$0'; exec bash"
exit 0

# set -x # Enable debugging

# # List the current user
# echo "Current user: $(whoami)"

# # Check if the script is run as root
# if [ "$EUID" -ne 0 ]; then
#     echo "This script must be run as root. Opening a new terminal with sudo..."
#     echo "EUID: $EUID"
#     echo "Script path: $0"
#     if command -v gnome-terminal > /dev/null 2>&1; then
#         gnome-terminal -- bash -c "sudo bash '$0'; exec bash"
#     elif command -v xterm > /dev/null 2>&1; then
#         xterm -e "sudo bash '$0'"
#     elif command -v konsole > /dev/null 2>&1; then
#         konsole --noclose -e "sudo bash '$0'"
#     else
#         echo "No supported terminal emulator found. Please run this script with sudo."
#         exit 1
#     fi
#     exit 0
# fi

# # Refresh the terminal
# exec bash

# # Rest of your script (if run as root)
# echo "Running as root."