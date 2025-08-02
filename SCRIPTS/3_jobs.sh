#!/bin/bash

#adjust simulation number
for i in $(seq -w 0 4999); do
    cd ../MD/test${i}
    ~/deepmd-kit/bin/mpirun ~/deepmd-kit/bin/lmp_mpi < input.lmp > lmp.out &
done
