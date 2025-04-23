source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash
echo 2 | gmx gyrate -f md_corrected.xtc -s frame_cluster.tpr -o rg_ph6.xvg 
echo 2 2 | gmx mindist -f md_corrected.xtc -s frame_cluster.tpr -on numcount_ph6.xvg
