#!/bin/bash

# Function to get system serial number
get_serial_number() {
  sudo dmidecode -s system-serial-number
}

# Function to get system manufacturer
get_manufacturer() {
  sudo dmidecode -s system-manufacturer
}

# Function to get system product name (brand/model)
get_product_name() {
  sudo dmidecode -s system-product-name
}


# Main script
echo "System Serial Number: $(get_serial_number)"
echo "System Manufacturer: $(get_manufacturer)"
echo "System Product Name: $(get_product_name)"


