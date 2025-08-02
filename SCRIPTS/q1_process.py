# Barrier value
q = 4.23
count = 0

for i in range(5000):
    folder = f"../MD/test{i:04d}"

    with open(f"{folder}/q_1.colvars.traj", 'r') as f1, open(f"{folder}/num.traj", 'w') as f2:
        lines = f1.readlines()
        lines = [line for line in lines if not line.startswith('#')]

        q0 = float(lines[0].split()[1])
        q3 = float(lines[3].split()[1])
        V0 = (q3 - q0) / 3

        f2.write("#step qt θt V0 Nt\n")

        for line in lines:
            parts = line.split()
            step, qt = parts[0], float(parts[1])
            θt = 1 if qt > q else 0
            Nt = V0 * θt
            f2.write(f"{step} {qt} {θt} {V0} {Nt}\n")

    count += 1

print(f"Done. Total {count} num.traj is generated.")
