source ~/apps/gromacs-2024.3/build/scripts/GMXRC.bash

python cgenff_charmm2gmx_py3_nx2.py TZP otrip_zip_8_ph6.cgenff.mol2 otrip_zip_8_ph6.str charmm36-jul2022.ff

gmx_mpi editconf -f tzp_ini.pdb  -o conf_b.gro -bt dodec -d 2
gmx_mpi solvate -cp conf_b.gro -cs spc216.gro -o conf_s.gro -p tzp.top
gmx_mpi grompp -f ions.mdp -c conf_s.gro -r conf_s.gro -o ions.tpr -maxwarn 1 -p tzp.top
gmx_mpi genion -s ions.tpr -o conf_i.gro -p tzp.top -conc 0.15 -neutral << EOF
4
EOF
gmx_mpi make_ndx -f conf_i.gro -o index.ndx << EOF
q
EOF 
gmx_mpi genrestr -f conf_i.gro -o rest_tzp.itp -n index.ndx << EOF
2
EOF
#Add these to tzp.itp:
##ifdef POSRES
##include "rest_tzp.itp
##endif
