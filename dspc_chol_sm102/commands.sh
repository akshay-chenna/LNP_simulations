python python3_insane_M3_lipids.py -salt 0.15 -sol W -o sm102_standard.gro -l DSPC:1 -l CHOL:4 -l S1D:5 -p topol.top -pbc hexagonal -box 9,9,9,0,0,5,0,0,0
source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash
gmx_mpi grompp -f em.mdp -c sm102_standard.gro -p topol.top -o em.tpr
gmx_mpi mdrun -s em.tpr -v -x em.xtc -c em.gro

gmx_mpi make_ndx -f sm102_standard.gro -o index.ndx
gmx_mpi grompp -f eq.mdp -p topol.top -c em.gro -o eq.tpr -n index.ndx -maxwarn 1
gmx_mpi mdrun -s eq.tpr -v -x eq.xtc -c eq.gro

gmx_mpi grompp -f md.mdp -p topol.top -c eq.gro -o md.tpr -n index.ndx

export OMP_NUM_THREADS=48
export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d
nohup mpirun -np 1 gmx_mpi mdrun -v -s md.tpr -o md.trr -x md.xtc -cpo md.cpt -e md.edr -g md.log -c md.gro -ntomp 48 -nstlist 200 -nb gpu -bonded gpu &
gmx_mpi grompp -f sa.mdp -p topol.top -c md.gro -o sa.tpr -n index.ndx
nohup mpirun -np 2 gmx_mpi mdrun -v -s sa.tpr -o sa.trr -x sa.xtc -cpo sa.cpt -e sa.edr -g sa.log -c sa.gro -ntomp 48 -nstlist 200 -nb gpu -bonded gpu &

gmx_mpi trjconv -f sa.xtc -s sa.tpr -pbc nojump -o nojump.xtc
