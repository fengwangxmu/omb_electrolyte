#!/usr/bin/env python
import numpy as np
from ase.io import read, write
from ase import Atoms
import glob

sys = glob.glob("*/")

for s in sys:
    type = [int(i) for i in np.loadtxt(s + "/type.raw")]
    type_map = []
        
    f = open(s +"/type_map.raw", "r")
    for r in f.readlines():
        type_map.append(r.strip('\n'))
    
    sym_dict = dict(zip(range(len(type_map)), type_map))
    cs = [sym_dict[specie] for specie in type]
    
    forces = np.load(s + "/set.000/force.npy")
    energy = np.load(s + "/set.000/energy.npy")
    box    = np.load(s + "/set.000/box.npy")
    pos    = np.load(s + "/set.000/coord.npy")
    virial = np.load(s + "/set.000/virial.npy")
    nat = len(type)
    
    frcs = forces.reshape(len(forces), nat, 3)
    poss = pos.reshape(len(pos), nat, 3)
    boxs = box.reshape(len(box), 3, 3)
    
    ats = []
    for i in range(len(forces)):
        at = Atoms(cs, poss[i], cell = boxs[i])
        at.set_array("forces", frcs[i])
        at.info['energy'] = energy[i]
        at.info['virial'] = virial[i]
        at.pbc = True
        ats.append(at)
    
    write(s.replace("/", "") +".xyz", ats)
