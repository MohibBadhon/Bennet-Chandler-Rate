#!/bin/bash

for x in {0000..4999}; do cd ../MD/test$x ; tail -n 20 q_1.colvars.traj > last20.dat ; awk '{ total += $2; count++ } END { print total/count }' last20.dat > mean ; cd .. ; done

cat ../MD/test*/mean > ../MD/mean_all.dat

below_count=0
above_count=0

while read -r value; do
    if (( $(echo "$value < 4.23" | bc -l) )); then
        ((below_count++))
    else
        ((above_count++))
    fi
done < ../MD/mean_all.dat

echo "Number of values below 4.23: $below_count"
echo "Number of values above 4.23: $above_count"

rm ../MD/test*/mean ../MD/test*/last20.dat ../MD/mean_all.dat
