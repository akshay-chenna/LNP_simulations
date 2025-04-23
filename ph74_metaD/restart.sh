export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps1
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d

mpirun -np 1 gmx_mpi mdrun -deffnm md -v -s md.tpr -cpi md.cpt -ntomp 1 -nstlist 200 -nb gpu -bonded gpu -pme gpu -update gpu
