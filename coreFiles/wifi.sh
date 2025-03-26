#!/bin/bash

# Function to check if WiFi is connected
check_wifi_connection() {
    if nmcli -t -f WIFI g | grep -q "enabled"; then
        if nmcli -t -f ACTIVE,SSID dev wifi | grep -q "^yes"; then
            echo "WiFi is connected."
            return 0
        else
            echo "WiFi is enabled but not connected."
            return 1
        fi
    else
        echo "WiFi is disabled."
        return 2
    fi
}

# Function to connect to a WiFi network
connect_to_wifi() {
    read -p "Enter WiFi SSID: " ssid
    read -sp "Enter WiFi Password: " password
    echo
    nmcli dev wifi connect "$ssid" password "$password" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Successfully connected to WiFi."
    else
        echo "Failed to connect to WiFi. Please check your credentials."
    fi
}

# Main script logic
check_wifi_connection
status=$?

if [ $status -eq 1 ] || [ $status -eq 2 ]; then
    echo "Attempting to connect to WiFi..."
    connect_to_wifi
elif [ $status -eq 0 ]; then
    echo "No action needed. WiFi is already connected and working."
fi