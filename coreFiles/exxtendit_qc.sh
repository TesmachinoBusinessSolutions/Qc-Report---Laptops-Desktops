#!/bin/bash

# Source the prep.sh script to set up the environment
sudo bash prep.sh

read -p "Enter the QC person's name: " qc_name
echo "Welcome, $qc_name!"

# Rest of the script remains unchanged
while true; do
    echo "Select an option to display system information:"
    echo "1) System Information"
    echo "2) RAM Information"
    echo "3) CPU Information"
    echo "4) Storage Information"
    echo "5) Battery Information"
    echo "6) Ethernet Information"
    echo "7) Wireless Information"
    echo "8) Run All in Sequence"
    echo "9) Save All to File (System Serial Number)"
    echo "10) Exit"
    read -p "Enter your choice [1-10]: " choice

    case $choice in
        1)
            echo "--- System Information ---"
            sudo bash systemdetails.sh
            echo
            ;;
        2)
            echo "--- RAM Information ---"
            sudo bash ram.sh
            echo
            ;;
        3)
            echo "--- CPU Information ---"
            sudo bash processor.sh
            echo
            ;;
        4)
            echo "--- Storage Information ---"
            echo "M.2 Information:"
            sudo bash nvme.sh
            echo
            echo "HDD Information:"
            sudo bash hdd.sh
            echo
            ;;
        5)
            echo "--- Battery Information ---"
            sudo bash battery.sh
            echo
            ;;
        # 6)
        #     echo "--- Ethernet Information ---"
        #     sudo ./ethernet.sh
        #     echo
        #     ;;
        # 7)
        #     echo "--- Wireless Information ---"
        #     sudo ./wifi.sh
        #     echo
        #     ;;
        8)
            echo "========================================"
            echo "         Running All in Sequence        "
            echo "========================================"

            echo "--- Running systemdetails.sh ---"
            sudo bash systemdetails.sh
            echo "Completed systemdetails.sh."
            sleep 2

            echo "--- Running ram.sh ---"
            sudo bash ram.sh
            echo "Completed ram.sh."
            sleep 2

            echo "--- Running processor.sh ---"
            sudo bash processor.sh
            echo "Completed processor.sh."
            sleep 2

            echo "--- Running nvme.sh ---"
            sudo bash nvme.sh
            echo "Completed nvme.sh."
            sleep 2

            echo "--- Running hdd.sh ---"
            sudo bash hdd.sh
            echo "Completed hdd.sh."
            sleep 2

            echo "--- Running battery.sh ---"
            sudo bash battery.sh
            echo "Completed battery.sh."
            sleep 2

            # Uncomment the following sections if needed
            # echo "--- Running ethernet.sh ---"
            # sudo ./ethernet.sh
            # echo "Completed ethernet.sh."
            # sleep 2

            # echo "--- Running wifi.sh ---"
            # sudo ./wifi.sh
            # echo "Completed wifi.sh."
            # sleep 2

            echo "========================================"
            echo "       All Scripts Executed Successfully"
            echo "========================================"
            echo
            ;;
        9)
            serial_number=$(sudo dmidecode -s system-serial-number)
            timestamp=$(date +"%Y%m%d_%H%M%S")
            report_folder="../report"
            sudo mkdir -p "$report_folder"
            output_file="${report_folder}/${serial_number}.txt"

            if [ -f "$output_file" ]; then
            output_file="${report_folder}/${serial_number}_${timestamp}.txt"
            fi

            echo "--- Saving All Information to File: $output_file ---"

            {
            echo "========================================" >> "$output_file"
            echo "           QC Report Summary            " >> "$output_file"
            echo "========================================" >> "$output_file"
            echo "QC Person: $qc_name" >> "$output_file"
            echo "Generated On: $(date)" >> "$output_file"
            echo "========================================" >> "$output_file"
            echo >> "$output_file"

            echo "----------------------------------------" >> "$output_file"
            echo "           System Information           " >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
            sudo bash systemdetails.sh >> "$output_file" 2>&1
            echo >> "$output_file"

            echo "----------------------------------------" >> "$output_file"
            echo "             RAM Information            " >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
            sudo bash ram.sh >> "$output_file" 2>&1
            echo >> "$output_file"

            echo "----------------------------------------" >> "$output_file"
            echo "             CPU Information            " >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
            sudo bash processor.sh >> "$output_file" 2>&1
            echo >> "$output_file"

            echo "----------------------------------------" >> "$output_file"
            echo "           Storage Information          " >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
            echo "M.2 Information:" >> "$output_file"
            sudo bash nvme.sh >> "$output_file" 2>&1
            echo >> "$output_file"
            echo "HDD Information:" >> "$output_file"
            sudo bash hdd.sh >> "$output_file" 2>&1
            echo >> "$output_file"

            echo "----------------------------------------" >> "$output_file"
            echo "           Battery Information          " >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
            sudo bash battery.sh >> "$output_file" 2>&1
            echo >> "$output_file"

            # Uncomment the following sections if needed
            # echo "----------------------------------------" >> "$output_file"
            # echo "          Ethernet Information          " >> "$output_file"
            # echo "----------------------------------------" >> "$output_file"
            # sudo ./ethernet.sh >> "$output_file" 2>&1
            # echo >> "$output_file"

            # echo "----------------------------------------" >> "$output_file"
            # echo "          Wireless Information          " >> "$output_file"
            # echo "----------------------------------------" >> "$output_file"
            # sudo ./wifi.sh >> "$output_file" 2>&1
            # echo >> "$output_file"

            if [ ! -s "$output_file" ]; then
            echo "Error: Failed to save information. The output file is empty."
            sudo rm -f "$output_file"
            else
            echo "All information saved to $output_file"
            fi
            echo
            }
            ;;
        10)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            
    esac
done