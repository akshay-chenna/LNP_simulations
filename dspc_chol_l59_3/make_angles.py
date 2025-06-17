from collections import defaultdict

def find_angles_from_bonds(bonds):
    """
    Finds all unique bond angles from a list of bonds.

    An angle is a sequence of three atoms A-B-C, where B is the central atom.
    The function finds all atoms 'B' that are connected to at least two other
    atoms and lists all unique A-B-C combinations.

    Args:
        bonds (list of tuples): A list where each tuple represents a bond
                                between two atoms, e.g., [(1, 3), (1, 4), ...].

    Returns:
        list of tuples: A sorted list of all unique angles, where each angle
                        is represented as a tuple (atom1, center_atom, atom2).
                        The outer atoms are sorted to ensure uniqueness.
    """
    adj = defaultdict(set)
    for atom1, atom2 in bonds:
        adj[atom1].add(atom2)
        adj[atom2].add(atom1)

    angles = []
    for center_atom in adj:
        neighbors = list(adj[center_atom])
        if len(neighbors) >= 2:
            for i in range(len(neighbors)):
                for j in range(i + 1, len(neighbors)):
                    atom_a = neighbors[i]
                    atom_c = neighbors[j]
                    angle_tuple = tuple(sorted((atom_a, atom_c)))
                    angles.append((angle_tuple[0], center_atom, angle_tuple[1]))

    return sorted(angles)

# --- Your Input Data ---
bond_list_str = """
1,2
2,3
3,4
4,5
5,6
6,7
7,8
8,9
9,10
8,11
11,12
4,13
13,14
14,15
15,16
16,17
17,18
16,19
19,20
"""

# Convert the string input into a list of tuples
bonds_input = [tuple(map(int, line.split(','))) for line in bond_list_str.strip().split('\n')]

# --- Run the code and print the result ---
found_angles = find_angles_from_bonds(bonds_input)

print("Found Angles (comma-delimited):")
# Modified print loop for comma-delimited output
for angle in found_angles:
    print(",".join(map(str, angle)))
