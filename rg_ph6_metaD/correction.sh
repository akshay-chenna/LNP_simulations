source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash

echo 2 0 | gmx_mpi trjconv -f em1.gro -s em1.tpr -o frame_cluster.gro -pbc cluster
gmx_mpi grompp -f md.mdp -c frame_cluster.gro -o frame_cluster.tpr -p tzp.top
echo 2 | gmx_mpi trjconv -f md.xtc -o md_corrected.xtc -s frame_cluster.tpr -pbc nojump
echo 2 | gmx_mpi trjconv -f md_corrected.xtc -o mdframe.pdb -e 0 -tu ns -s frame_cluster.tpr
#echo 20 | gmx_mpi trjconv -f md.xtc -o md_corrected_immunogen_bb.xtc -s frame_cluster.tpr -pbc nojump -n index.ndx
#echo 20 | gmx_mpi trjconv -f md_corrected.xtc -o mdframe_immunogen_bb.pdb -b 1000 -tu ns -s frame_cluster.tpr -n index.ndx
