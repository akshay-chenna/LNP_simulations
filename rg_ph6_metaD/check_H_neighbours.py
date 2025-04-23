#!/usr/bin/env python

from rdkit import Chem

# Load both ligand structures. 
# The removeHs=False keeps explicit hydrogens from the PDB.
lig1 = Chem.MolFromPDBFile("ph74.pdb", removeHs=False)
lig2 = Chem.MolFromPDBFile("ph6.pdb", removeHs=False)

if lig1 is None or lig2 is None:
    raise ValueError("Could not parse one of the PDB files with RDKit.")

# Iterate over atoms in parallel.
for a1, a2 in zip(lig1.GetAtoms(), lig2.GetAtoms()):
    # Skip if this atom is hydrogen
    if a1.GetAtomicNum() == 1 or a2.GetAtomicNum() == 1:
        continue

    # RDKit index (0-based)
    idx1 = a1.GetIdx()
    idx2 = a2.GetIdx()

    # Optional: if the PDB has 'ATOM/HETATM' records with a SerialNumber,
    # we can retrieve that instead of (or in addition to) the RDKit index.
    serial1 = a1.GetPDBResidueInfo().GetSerialNumber() if a1.GetPDBResidueInfo() else None
    serial2 = a2.GetPDBResidueInfo().GetSerialNumber() if a2.GetPDBResidueInfo() else None

    # Atom names from the PDB record
    # If the PDBResidueInfo is missing, fall back on the element symbol or a placeholder
    if a1.GetPDBResidueInfo():
        name1 = a1.GetPDBResidueInfo().GetName().strip()
    else:
        name1 = a1.GetSymbol()  # fallback

    if a2.GetPDBResidueInfo():
        name2 = a2.GetPDBResidueInfo().GetName().strip()
    else:
        name2 = a2.GetSymbol()  # fallback

    # Count how many hydrogens neighbor each heavy atom
    hcount1 = sum(1 for nbr in a1.GetNeighbors() if nbr.GetAtomicNum() == 1)
    hcount2 = sum(1 for nbr in a2.GetNeighbors() if nbr.GetAtomicNum() == 1)

    if hcount1 != hcount2:
        print("========== DIFFERENCE FOUND ==========")
        print(f"RDKit idx: {idx1} vs. {idx2}")
        if serial1 is not None and serial2 is not None:
            print(f"PDB Serial: {serial1} vs. {serial2}")
        print(f"Atom names: {name1} vs. {name2}")
        print(f"H count   : {hcount1} vs. {hcount2}")
        print("======================================\n")

