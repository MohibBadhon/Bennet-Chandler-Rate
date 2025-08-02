#!/bin/bash

# Function to generate a unique random number
generate_unique_number() {
    while true; do
        num=$(shuf -i 1000000-9999999 -n 1)
        if ! [[ "${used_numbers[@]}" =~ "$num" ]]; then
            used_numbers+=($num)
            echo $num
            break
        fi
    done
}

# Array to store used numbers
declare -a used_numbers

# Loop from 00000 to 4999
for i in {0000..4999}; do
    # Generate a unique random number
    random_num=$(generate_unique_number)
    # replace the seed
    sed -i "s/ 4928459 / $random_num /g" "../MD/test$i/input.lmp"
done

echo "All velocities files are processed."
