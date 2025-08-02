#!/bin/bash

# File path
input_file="../MD/mean_all.dat"

# Total number of values per group
group_size=100

# Initialize counters
start=0

# Read the file line by line
while true; do
    below_count=0
    above_count=0

    # Process a group of `group_size` lines
    for ((i=0; i<group_size; i++)); do
        if read -r value; then
            if (( $(echo "$value < 4.23" | bc -l) )); then
                ((below_count++))
            else
                ((above_count++))
            fi
        else
            # Break the loop if we reach the end of the file
            break 2
        fi
    done

    # Print the result for the current group
    end=$((start + group_size - 1))
    printf "%04d-%04d:\n" "$start" "$end"
    echo "Above 4.23: $above_count"
    echo "Below 4.23: $below_count"
    echo

    # Update the start for the next group
    start=$((start + group_size))
done < "$input_file"
