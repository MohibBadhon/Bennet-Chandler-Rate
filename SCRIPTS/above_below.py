import glob
import numpy as np

results = []

for file_path in sorted(glob.glob("../MD/test*/q_1.colvars.traj")):
    try:
        data = np.loadtxt(file_path, usecols=1)
        results.append(np.mean(data[-20:]))
    except:
        pass

below = sum(1 for x in results if x < 4.18)
above = len(results) - below

print(f"Below 4.18: {below}")
print(f"Above 4.18: {above}")
