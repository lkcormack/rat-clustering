#!/bin/bash

nRats=15

# Set the source and destination directories
source_dir="/Users/lkc/Library/CloudStorage/Box-Box/MovementAnalysisData_DLC/${nRats}_complete"
dest_dir="/Users/lkc/Documents/GitHub/rat-clustering/data/${nRats}Rats"

# Initialize a counter
counter=1

# Loop through each subdirectory in the source directory
for sub_dir in "${source_dir}"/*/Average_Position; do
    # Check if the subdirectory exists
    if [ -d "${sub_dir}" ]; then
        # Copy the subdirectory to the destination directory with the new name
        cp -r "${sub_dir}" "${dest_dir}/Average_Position_$(printf "%02d" "${counter}")"
        # Increment the counter
        counter=$((counter + 1))
    fi
    echo "${sub_dir}"
done
