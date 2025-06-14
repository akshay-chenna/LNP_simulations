python python3_insane_M3_lipids.py -salt 0.15 -sol W -o l59_standard.gro -l L59:1 -p topol.top -pbc hexagonal -box 9,9,9,0,0,5,0,0,0
#python python3_insane_M3_lipids.py -salt 0.15 -sol W -o l59_standard.gro -l L59:1 -p topol.top -pbc hexagonal -box 12,12,12
#python python3_insane_M3_lipids.py -salt 0.15 -sol W -o l59_standard.gro -l L59:1 -p topol.top -pbc cubic -box 9,9,10

source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash

sed -i -e '1d' topol.top
sed -i -e '1 i #include "martini_v3.0.0.itp"\n#include "martini_v3.0.0_ffbonded_v2_openbeta.itp"\n#include "martini_v3.0.0_phospholipids_PC_v2_openbeta.itp"\n#include "martini_v3.0.0_sterols_v1.itp"\n#include "L59.itp"\n#include "martini_v3.0.0_solvents_v1.itp"\n#include "martini_v3.0.0_ions_v1.itp"' topol.top

gmx_mpi grompp -f em.mdp -c l59_standard.gro -p topol.top -o em.tpr -maxwarn 1
gmx_mpi mdrun -s em.tpr -v -x em.xtc -c em.gro

gmx_mpi make_ndx -f l59_standard.gro -o index.ndx << EOF
2
!2
name 7 Bilayer
name 8 Solvent
q
EOF

export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps1
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d
export OMP_NUM_THREADS=8

gmx_mpi grompp -f eq0.mdp -p topol.top -c em.gro -o eq0.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq0.tpr -v -x eq0.xtc -c eq0.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f eq1.mdp -p topol.top -c eq0.gro -o eq1.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq1.tpr -v -x eq1.xtc -c eq1.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f eq2.mdp -p topol.top -c eq1.gro -o eq2.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq2.tpr -v -x eq2.xtc -c eq2.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f md.mdp -p topol.top -c eq2.gro -o md.tpr -n index.ndx
mpirun -np 1 gmx_mpi mdrun -v -s md.tpr -o md.trr -x md.xtc -cpo md.cpt -e md.edr -g md.log -c md.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f md2.mdp -p topol.top -c md.gro -o md2.tpr -n index.ndx
mpirun -np 1 gmx_mpi mdrun -v -s md2.tpr -o md2.trr -x md2.xtc -cpo md2.cpt -e md2.edr -g md2.log -c md2.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi grompp -f sa.mdp -p topol.top -c md2.gro -o sa.tpr -n index.ndx
mpirun -np 1 gmx_mpi mdrun -v -s sa.tpr -o sa.trr -x sa.xtc -cpo sa.cpt -e sa.edr -g sa.log -c sa.gro -ntomp 8 -nb gpu -bonded gpu

gmx_mpi trjconv -f sa.xtc -s sa.tpr -pbc nojump -o nojump.xtc
