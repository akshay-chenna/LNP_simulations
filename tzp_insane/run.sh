python python3_insane_M3_lipids.py -salt 0.15 -sol W -o tzp_standard.gro -l TZP:1 -p topol.top -pbc hexagonal -box 9,9,9,0,0,5,0,0,0

sed -i -e '1d' topol.top
sed -i -e '1 i #include "martini_v3.0.0.itp"\n#include "martini_v3.0.0_ffbonded_v2_openbeta.itp"\n#include "Martini_v1_tails-2.itp"\n#include "gmx_out6.itp"\n#include "martini_v3.0.0_solvents_v1.itp"\n#include "martini_v3.0.0_ions_v1.itp"' topol.top

gmx_mpi grompp -f em.mdp -c tzp_standard.gro -p topol.top -o em.tpr -maxwarn 1
gmx_mpi mdrun -s em.tpr -v -x em.xtc -c em.gro

gmx_mpi make_ndx -f tzp_standard.gro -o index.ndx << EOF
2
!2
name 7 Bilayer
name 8 Solvent
q
EOF

gmx_mpi grompp -f eq.mdp -p topol.top -c em.gro -o eq.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq.tpr -v -x eq.xtc -c eq.gro

gmx_mpi grompp -f eq2.mdp -p topol.top -c eq.gro -o eq2.tpr -n index.ndx -maxwarn 2
gmx_mpi mdrun -s eq2.tpr -v -x eq2.xtc -c eq2.gro

export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d
export OMP_NUM_THREADS=32
gmx_mpi grompp -f md.mdp -p topol.top -c eq.gro -o md.tpr -n index.ndx
nohup mpirun -np 1 gmx_mpi mdrun -v -s md.tpr -o md.trr -x md.xtc -cpo md.cpt -e md.edr -g md.log -c md.gro -ntomp 32 -nstlist 200 -nb gpu -bonded gpu &

gmx_mpi grompp -f sa.mdp -p topol.top -c md.gro -o sa.tpr -n index.ndx
nohup mpirun -np 1 gmx_mpi mdrun -v -s sa.tpr -o sa.trr -x sa.xtc -cpo sa.cpt -e sa.edr -g sa.log -c sa.gro -ntomp 32 -nstlist 200 -nb gpu -bonded gpu &

gmx_mpi trjconv -f sa.xtc -s sa.tpr -pbc nojump -o nojump.xtc
