export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps1
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d

source ~/apps/gromacs-2024.2/build/scripts/GMXRC.bash

export OMP_NUM_THREADS=16

#gmx_mpi convert-tpr -extend 2000000 -o md_extended.tpr -s md.tpr -generate_velocities no

mpirun -np 1 gmx_mpi mdrun -deffnm md -v -s md_extended.tpr -cpi md.cpt -ntomp 16 -nstlist 200 -nb gpu -bonded gpu -pme gpu -update gpu
