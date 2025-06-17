python python3_insane_M3_lipids.py -salt 0.15 -sol W -o l59_standard.gro -l DSPC:3 -l CHOL:4 -l L59:3 -p topol.top -pbc hexagonal -box 9,9,9,0,0,5,0,0,0 # slanted to avoid pbc artifacts in the gel state

source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash
export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps1
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d
export OMP_NUM_THREADS=8

sed -i -e '1d' topol.top
sed -i -e '1 i #include "martini_v3.0.0.itp"\n#include "martini_v3.0.0_ffbonded_v2_openbeta.itp"\n#include "martini_v3.0.0_phospholipids_PC_v2_openbeta.itp"\n#include "martini_v3.0.0_sterols_v1.itp"\n#include "L59.itp"\n#include "martini_v3.0.0_solvents_v1.itp"\n#include "martini_v3.0.0_ions_v1.itp"' topol.top

gmx_mpi grompp -f em.mdp -c l59_standard.gro -p topol.top -o em.tpr -maxwarn 1
gmx_mpi mdrun -s em.tpr -v -x em.xtc -c em.gro

gmx_mpi make_ndx -f l59_standard.gro -o index.ndx << EOF
2 | 3 | 4
!9
name 9 Bilayer
name 10 Solvent
q
EOF

gmx_mpi grompp -f eq0.mdp -p topol.top -c em.gro -o eq0.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq0.tpr -v -x eq0.xtc -c eq0.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f eq1.mdp -p topol.top -c eq0.gro -o eq1.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq1.tpr -v -x eq1.xtc -c eq1.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f eq2.mdp -p topol.top -c eq1.gro -o eq2.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq2.tpr -v -x eq2.xtc -c eq2.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f eq3.mdp -p topol.top -c eq2.gro -o eq3.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq3.tpr -v -x eq3.xtc -c eq3.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f sa.mdp -p topol.top -c eq3.gro -o sa.tpr -n index.ndx
mpirun -np 1 gmx_mpi mdrun -v -s sa.tpr -o sa.trr -x sa.xtc -cpo sa.cpt -e sa.edr -g sa.log -c sa.gro -ntomp 8 -nb gpu -bonded gpu

echo 0 | gmx_mpi trjconv -f sa.xtc -s sa.tpr -pbc nojump -o nojump.xtc

