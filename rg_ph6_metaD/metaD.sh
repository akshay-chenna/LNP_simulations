source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash
export OMP_NUM_THREADS=24

export CUDA_MPS_PIPE_DIRECTORY=/tmp/mps1
mkdir -p $CUDA_MPS_PIPE_DIRECTORY
nvidia-cuda-mps-control -d

mpirun -np 1 gmx_mpi mdrun -v -s md.tpr -o md.trr -x md.xtc -cpo md.cpt -e md.edr -g md.log -c md.gro -ntomp 24 -nstlist 200 -nb gpu -bonded gpu -pme gpu -plumed plumed.dat
plumed sum_hills --hills HILLS --mintozero
#plumed driver --plumed plumed2.dat --mf_xtc md.xtc
#plumed sum_hills --hills HILLS --mintozero --idw dcom1 --kt 2.5
#plumed sum_hills --hills HILLS --mintozero --idw dcom1 --kt 2.5 --outfile fes_dcom1.dat
#plumed sum_hills --hills HILLS --mintozero --idw dcom2 --kt 2.5 --outfile fes_dcom2.dat
