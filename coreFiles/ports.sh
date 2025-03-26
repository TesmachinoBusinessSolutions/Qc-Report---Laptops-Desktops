#!/bin/bash

# Script to monitor physical ports like USB and HDMI

echo "Monitoring physical ports (USB and HDMI). Press Ctrl+C to stop."

while true; do
    clear
    echo "Connected USB Devices:"
    echo "----------------------"
    lsusb
    echo
    echo "Connected HDMI/Display Ports:"
    echo "-----------------------------"
    xrandr | grep " connected"
    sleep 2
done