#!/bin/bash

mkdir -p ../MD/test0000

# Split trajectory into frames
split -l 767 -d -a 4 ../prep/traj.xyz ../prep/first

cp ../prep/input.lmp         ../MD/test0000/
cp ../prep/data.lmpdat       ../MD/test0000/
cp ../prep/colvar_inp        ../MD/test0000/

#fix the steps for simulation
sed -i '/run/c\run           2000' ../MD/test0000/input.lmp
sed -i '/velocity/c\velocity       all create 300.0 4928459 dist uniform' ../MD/test0000/input.lmp
sed -i '/forceConstant/c\forceConstant 0' ../MD/test0000/colvar_inp
sed -i '/colvarsTrajFrequency/c\colvarsTrajFrequency 1' ../MD/test0000/colvar_inp

# Replicate test0000 to test0001...test4999
for i in $(seq -w 1 4999); do
    cp -r ../MD/test0000 ../MD/test${i}
done

# Replace conf.xyz in each directory
for i in $(seq -w 0 4999); do
    cp ../prep/first${i} ../MD/test${i}/conf.xyz
done

rm ../prep/first*

echo "Done: Prepared test directories."
