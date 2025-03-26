#!/bin/bash

# Function to get adapter connecting status
get_adapter_status() {
  upower -e | grep AC | awk '{print $1}'
}

# Function to get battery status
get_battery_status() {
  battery_device=$(upower -e | grep battery)
  if [[ -n "$battery_device" ]]; then
    upower -i "$battery_device" | grep state | awk '{print $2}'
  else
    echo "Battery device not found."
    return 1
  fi
}

# Function to get battery percentage
get_battery_percentage() {
  battery_device=$(upower -e | grep battery)
  if [[ -n "$battery_device" ]]; then
    upower -i "$battery_device" | grep percentage | awk -F': ' '{print $2}'
  else
    echo "Battery device not found."
    return 1
  fi
}

# Function to get battery energy-full
get_battery_energy_full() {
    battery_device=$(upower -e | grep battery)
    if [[ -n "$battery_device" ]]; then
        upower -i "$battery_device" | grep energy-full | awk -F': ' '{print $2}' | awk '{print $1}'
    else
        echo "Battery device not found."
        return 1
    fi
}

# Function to get battery energy-full-design
get_battery_energy_full_design() {
    battery_device=$(upower -e | grep battery)
    if [[ -n "$battery_device" ]]; then
        upower -i "$battery_device" | grep energy-full-design | awk -F': ' '{print $2}' | awk '{print $1}'
    else
        echo "Battery device not found."
        return 1
    fi
}

# Test Case: Battery discharge and charge capacity
test_battery_capacity() {
  echo "--- Battery Capacity Test ---"

  # Initial state
  initial_percentage=$(get_battery_percentage)
  initial_energy_full=$(get_battery_energy_full)
  initial_energy_full_design=$(get_battery_energy_full_design)

  echo "Initial Battery Percentage: $initial_percentage"
  echo "Initial Energy Full: $initial_energy_full"
  echo "Initial Energy Full Design: $initial_energy_full_design"

  read -p "Let battery discharge for a while (e.g., 10 minutes) and press Enter..."

  # After discharge
  discharge_percentage=$(get_battery_percentage)
  discharge_energy_full=$(get_battery_energy_full)

  echo "Battery Percentage after discharge: $discharge_percentage"
  echo "Energy Full after discharge: $discharge_energy_full"

  discharge_percentage_diff=$((initial_percentage - discharge_percentage))
  discharge_energy_full_diff=$((initial_energy_full - discharge_energy_full))

  echo "Discharge Percentage Difference: $discharge_percentage_diff%"
  echo "Discharge Energy Full Difference: $discharge_energy_full_diff"

  read -p "Plug in the adapter and let battery charge for a while (e.g., 10 minutes) and press Enter..."

  # After charge
  charge_percentage=$(get_battery_percentage)
  charge_energy_full=$(get_battery_energy_full)

  echo "Battery Percentage after charge: $charge_percentage"
  echo "Energy Full after charge: $charge_energy_full"

  charge_percentage_diff=$((charge_percentage - discharge_percentage))
  charge_energy_full_diff=$((charge_energy_full - discharge_energy_full))

  echo "Charge Percentage Difference: $charge_percentage_diff%"
  echo "Charge Energy Full Difference: $charge_energy_full_diff"

  echo "--- Test Complete ---"
}

# Main script
adapter_device=$(get_adapter_status)

if [[ -n "$adapter_device" ]]; then
  # Watch adapter connection status
  while true; do
    adapter_status=$(upower -i "$adapter_device" | grep online | awk '{print $2}')

    if [[ "$adapter_status" == "yes" ]]; then
      echo "Adapter is currently connected."
      read -p "Remove the adapter and press Enter to start the test..."
      test_battery_capacity
      break # Exit the loop after test
    else
      echo "Adapter is currently disconnected."
      read -p "Plug in the adapter and press Enter to start the test..."
      test_battery_capacity
      break # Exit the loop after test
    fi
    sleep 5 # Check every 5 seconds
  done
else
  echo "Adapter device not found. Please ensure the adapter is correctly detected."
fi