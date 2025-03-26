# Summary
 
# run.sh Script

## Overview
The script is a Bash utility designed to assist in performing quality control (QC) checks on a system. It provides an interactive menu for gathering and displaying various system information, as well as saving the collected data into a report file. The script is modular and relies on other scripts to fetch specific details about the system.

## Features
1. **Interactive Menu**: Allows the user to select from multiple options to display system information.
2. **System Information**: Fetches general system details using the `systemdetails.sh` script.
3. **RAM Information**: Displays memory details using the `ram.sh` script.
4. **CPU Information**: Provides processor details using the `processor.sh` script.
5. **Storage Information**: Displays both M.2 and HDD storage details using `nvme.sh` and `hdd.sh` scripts.
6. **Battery Information**: Fetches battery status using the `battery.sh` script.
7. **Run All in Sequence**: Executes all the above scripts sequentially to gather comprehensive system information.
8. **Save All to File**: Saves all gathered information into a timestamped report file, named after the system's serial number.
9. **Exit Option**: Allows the user to exit the script gracefully.

## Prerequisites
- The script requires `sudo` privileges to execute certain commands.
- Ensure the following scripts are present in the same directory or accessible via the script:
    - `prep.sh`
    - `systemdetails.sh`
    - `ram.sh`
    - `processor.sh`
    - `nvme.sh`
    - `hdd.sh`
    - `battery.sh`
    - (Optional) `ethernet.sh` and `wifi.sh` for network information.

## Usage
1. Run the script with:
     ```bash
     ./exxtendit_qc.sh
     ```
2. Enter the QC person's name when prompted.
3. Select an option from the menu to display or save system information:
     - Options 1-7 display specific system details.
     - Option 8 runs all scripts sequentially.
     - Option 9 saves all information to a report file.
     - Option 10 exits the script.

## Report Generation
- The report is saved in the `../report` directory.
- The filename is based on the system's serial number. If a file with the same name exists, a timestamp is appended to the filename.
- The report includes:
    - QC person's name
    - Timestamp of report generation
    - System, RAM, CPU, storage, and battery information
    - (Optional) Ethernet and wireless information if the corresponding scripts are enabled.

## Notes
- Some sections (e.g., Ethernet and Wireless Information) are commented out. Uncomment them if the corresponding scripts are available and required.
- The script ensures the output file is not empty. If the file is empty, it is deleted, and an error message is displayed.


## Usage
1. Ensure the script has executable permissions:
    ```chmod +x run.sh
    ```

2. Run the script:
    ```bash run.sh
    ```
## Error Handling
- If the `coreFiles` directory is not found, the script will exit with an error message.
- If the `exxtendit_qc.sh` script fails to execute, the script will exit with an error message.

## Output
- On successful execution, the script will display:
  ```
  exxtendit_qc executed successfully.
  ```

## Notes
- Ensure that the `exxtendit_qc.sh` script has the necessary permissions and dependencies to run correctly.
EOF

## Disclaimer
This script is intended for internal use and assumes the user has the necessary permissions and dependencies installed. Use with caution on production systems.
