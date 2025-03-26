#!/bin/bash

# Navigate to the coreFiles directory
cd coreFiles || { echo "coreFiles directory not found"; exit 1; }

# Run the exxtendit_qc script
sudo bash exxtendit_qc.sh || { echo "Failed to execute exxtendit_qc"; exit 1; }

echo "exxtendit_qc executed successfully."


