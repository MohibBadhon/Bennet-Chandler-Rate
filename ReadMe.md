## Backgraound
Rare events in molecular simulations—such as barrier crossings during chemical reactions or solvation transitions occur infrequently and are challenging to capture directly using standard Molecular Dynamics simulations. To observe and quantify such rare events, one must define a suitable reaction coordinate that tracks the system’s progress from one state to another. The use of reaction coordinates for computing rate constants was first introduced by Bennett in the context of solid-state diffusion and later generalized by Chandler to cover a wider range of reactive processes. This led to the development of the well-known Bennett–Chandler formalism for computing reaction rates from MD simulations.

The Bennett–Chandler approach separates the rate constant into two factors: a static term, representing the equilibrium probability of being at the dividing surface, and a dynamical correction, quantifying the probability that a trajectory starting at this surface reaches the product without recrossing. Unlike classical Transition State Theory (TST), this method does not require precise identification of the transition state. Instead, it introduces a time-dependent transmission coefficient, κ(t), which measures the fraction of such successful trajectories.

$$
\kappa(t) \equiv \frac{k_{A \rightarrow B}(t)}{k^{\mathrm{TST}}_{A \rightarrow B}} 
= \frac{
\left\langle \dot{q}(0) \, \delta(q(0) - q_1) \, \theta(q(t) - q_1) \right\rangle
}{
\frac{1}{2} \left\langle |\dot{q}(0)| \right\rangle
}
$$

<p align="center">
  <img src="/figures/figure 1.png" width="400"/>
</p>

Figure 1: Schematic representation of a free energy surface along a reaction coordinate 𝑞, with reactant (A) and product (B) basins separated by a barrier. The peak of the barrier is located at 𝑞<sup>*</sup>, which is often chosen as the dividing surface 𝑞<sub>1</sub> in rate calculations, although its exact position is somewhat arbitrary within the formalism.

Here, _q_ is the reaction coordinate, with _q<sub>1</sub>_ defining the dividing surface-—typically placed at the transition state. The delta function _𝛿(q(0)-q<sub>1</sub>)_ ensures that all trajectories start exactly at this surface. The dot over _q_, written as _q̇(0)_, refers to the velocity along the reaction coordinate at time zero. The Heaviside step function _θ(q(t)-q<sub>1</sub>_) checks whether, after some time 𝑡, the trajectory has moved to the product side (i.e., _q_ > _q<sub>1</sub>_). The numerator, then, gives the flux of trajectories that start at the dividing surface and move toward products. The denominator, 0.5⟨∣_q̇(0)_∣⟩, comes from the TST flux and normalizes this expression. Together, the ratio defines κ(t), which corrects the TST rate by accounting for dynamical recrossings.

## Workflow
To reliably compute rate constants, begin with a well-converged free energy profile along the reaction coordinate q. The location of the barrier top (the dividing surface, q₁) can be determined by committor analysis or by identifying the peak of the free energy profile. Once q₁ is established, sample initial configurations around this point for further analysis.
Sampling is commonly performed by running a constrained MD simulation at q₁, applying a strong harmonic restraint to maintain the system near the barrier top. The generated snapshots from this simulation serve as initial conditions for a series of unbiased, short MD runs. These are often referred to as "shooting trajectories" and allow the system to evolve naturally from the transition state. Each trajectory should be sufficiently long to capture transitions into either reactant or product basins. Typically, a few picoseconds are sufficient, but this depends on the barrier height; if the barrier is small (~k<sub>B</sub>T), the coordinate may fluctuate between states before settling.
After collecting these trajectories, we evaluate the direction and fate of each one. Specifically, we calculate the numerator of the transmission coefficient κ(t) using a function N(t) that combines the initial velocity and the Heaviside step function based on whether the system reached the product side. The relevant values from a single trajectory may look like:

```
#step qt θt V0 Nt
0 4.23402524466966 1 -0.0022655275324898008 -0.0022655275324898008
1 4.23176574608357 1 -0.0022655275324898008 -0.0022655275324898008
2 4.22942453194268 0 -0.0022655275324898008 -0.0
...
2000 4.59618354500682 1 -0.0022655275324898008 -0.0022655275324898008
```
These values are then aggregated across all simulations to compute the average N(t) and average |V₀| across all time steps. The transmission coefficient is then computed as:

$$
\kappa(t) = \frac{ \langle N(t) \rangle }{ \frac{1}{2} \left\langle |\dot{q}(0)| \right\rangle }
$$


The result is a time series of κ(t), which begins at zero and increases as the system evolves. It is essential that κ(t) eventually reaches a plateau, indicating that recrossings have stabilized and the rate constant is accurate. A typical κ(t) curve might look like this:```

```
#step Nt V0 kt
0 2.91e-05 0.00150 0.0387
1 2.02e-04 0.00150 0.2696
2 3.59e-04 0.00150 0.4789
...
2000 8.22e-05 0.00150 0.1095
```
Once this plateau is reached, the final value of κ can be multiplied by the static TST prefactor to yield the corrected rate constant k(T). This completes the dynamical correction to transition state theory.


## Example
In this example, we consider the dissociation of a CaSO4 ion pair in bulk water and compute the corresponding rate constant using the Bennett-Chandler method.The reaction coordinate (RC) is defined as the distance between the Ca<sup>2+</sup> ion and the sulfur atom (S) in the sulfate group. Since the sulfate oxygens are harmonically constrained to the sulfur atom, this provides a simple yet effective RC.
This example assumes that a well-converged free energy profile is available, with a clear barrier separating states. To sample configurations near the top of this barrier, we run restrained MD simulations using [LAMMPS](https://www.lammps.org/#gsc.tab=0) and the [Colvars](https://colvars.github.io/master/colvars-refman-lammps.html) module, which allows us to constrain the system around the dividing surface. From this, we generate a large ensemble (5,000) of short, unbiased trajectories, the "shooting" simulations to capture the system's dynamics near the transition state.
An example MD simulation can be found in the ```prep/ ``` folder. A 0.25 ns simulation is performed at the barrier top to generate a diverse ensemble of initial configurations. These configurations are then split into 5,000 frames using the script ```1_rename.sh```, which also creates the necessary directory structure for each trajectory:
```
cd SCRIPTS/
bash 1_rename.sh
```
This script performs the following:
-Splits the long trajectory into individual snapshots.
-Copies template input files (```conf.xyz```,```input.lmp```, ```colvar_inp```, ```data.lmpdat```) into 5000 directories named ```test0000```, ```test0001```, ..., ```test4999```.
-Sets the force constant to zero and fixes a placeholder velocity seed.
Next, run the velocity randomization script: ```bash 2_velocity.sh```, which assigns unique random seeds for the initial velocity generation in each simulation, ensuring statistically independent runs. Once each folder has the necessary files, simulations can be launched with: ```bash 3_jobs.sh```. 
**Note**: This script launches all 5000 jobs in the background using mpirun. Please modify it as needed to suit cluster's job submission system, especially to avoid overloading the system.

Once the simulations complete, you can analyze whether the reaction coordinate sampled values on both sides of the barrier using ```bash above_below.sh```. This script averages the last 20 values of the reaction coordinate from each trajectory (q_1.colvars.traj) and reports the number of trajectories ending above and below the dividing plane. Next, compute the numerator of the transmission coefficient κ(t) from each simulation ```python q1_process.py``` and create ```num.traj``` file in each directory, containing time-resolved data. 
Finally, run the ensemble averaging script, ```python analysis.py```. This will gather all ```num.traj``` files and compute the transmission coefficient with respect to time. 
_κ(t)_ can be visualized using ```gnuplot``` , ```metplotlib``` or any other plotting tool. For example, 
```
plot 'result.traj' u 1:4 w l lw 3 title 'κ(t)'
```

<p align="center">
  <img src="/figures/figure2.png" width="400"/>
</p>

Once _κ(t)_ reaches a plateau, its final value can be multiplied by the static TST prefactor to obtain the fully corrected rate constant, 

$$
k = \kappa(t \to \infty) \times k_{\mathrm{TST}}
$$