obabel -ismiles trip_zip-8.smiles --p 6 -O trip_zip_8.pdb
obabel trip_zip_8.pdb -O test.pdb --gen3d
mv test.pdb trip_zip_8.pdb
obminimize -ff UFF -n 10000 -c 1e-9 trip_zip_8.pdb > otrip_zip_8_ph6.pdb
obabel otrip_zip_8_ph6.pdb -O otrip_zip_8_ph6.mol2
rm trip_zip_8.pdb
