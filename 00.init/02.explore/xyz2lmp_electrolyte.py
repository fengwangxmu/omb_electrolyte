#!/usr/bin/env python

from ase.io import read,write
from ase.io.lammpsdata import write_lammps_data

import random as r

atoms = read("simbox.xyz", ":")

atoms = r.sample(atoms, 50)
for idx, a in enumerate(atoms):
    write_lammps_data('conf-%d.lmp'%idx, a, atom_style='atomic', specorder = ["B", "C", "F", "H", "N", "Na", "O", "P", "S"])

