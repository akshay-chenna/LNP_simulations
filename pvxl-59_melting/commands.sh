touch blank.itp
python /home/akshay/apps/m3_bartender/write_bartender_inp.py --ndx cgbuilder.ndx --itp blank.itp --out bartender.inp
# modify the bartender.inp file to include bonds and angles (make_angles.py)
nohup bartender pvxl59.pdb bartender.inp &
