#!/usr/bin/env python

from ase.io import read, write, iread
from deepmd.calculator import DP
import numpy as np

calc = DP(model="graph.000.compress.pth")

for atoms in iread("out.xyz", ":"):
    atoms.calc = calc
    atoms.get_potential_energy()
    atoms.get_forces()
    stress = atoms.get_stress()
    virial = -atoms.get_stress(voigt=False)* np.linalg.det(atoms.get_cell())
    atoms.info['virial'] = virial
    write("dp.xyz", atoms, append = True)
