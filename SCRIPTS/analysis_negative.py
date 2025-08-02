import os
import numpy as np
import math
sum_Nt = {}
sum_V0 = {}
count = {}

for i in range(5000):
    dir_name = f"../MD/test{i:04d}"
    file_path = os.path.join(dir_name, "num.traj")
    if os.path.isfile(file_path):
        with open(file_path, 'r') as file:
            for line in file:
                if line.startswith("#"):
                    continue
                
                parts = line.split()
                step = int(parts[0])
                V0 = float(parts[3])
                Nt = float(parts[4])
                
                if step not in sum_Nt:
                    sum_Nt[step] = 0
                    sum_V0[step] = 0
                    count[step] = 0
                if  V0 < 0 :
                   sum_Nt[step] += Nt
                   sum_V0[step] += V0
                   count[step] += 1

output_file = "result_neg.traj"
with open(output_file, 'w') as file:
    file.write("#step Nt V0 kt\n")
    for step in sorted(sum_Nt.keys()):
        avg_Nt = sum_Nt[step] / count[step]
        avg_V0 = (sum_V0[step] / count[step])
        kt = avg_Nt / ( avg_V0)
        file.write(f"{step} {avg_Nt} {avg_V0} {kt}\n")

