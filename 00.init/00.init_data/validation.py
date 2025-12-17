#!/usr/bin/env python

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.gridspec as gridspec
from sklearn.metrics import mean_squared_error
import glob 
from ase.io import iread

lw2=2
lw = 2
plot_fig = 1
fs = 18

dft_energy = []
dft_forces = np.array([])
dft_virial = np.array([])

for atoms in iread("out.xyz", "::"):
    dft_energy.append(atoms.get_potential_energy()/atoms.get_global_number_of_atoms())
    dft_forces = np.append(dft_forces, atoms.get_forces())
    dft_virial = np.append(dft_virial, np.array(atoms.info.get('virial', np.full((3, 3), np.nan))))

dft_energy = np.array(dft_energy)

mlp_energy = []
mlp_forces = np.array([])
mlp_virial = np.array([])
for atoms in iread("dp.xyz", "::"):
    mlp_energy.append(atoms.get_potential_energy()/atoms.get_global_number_of_atoms())
    mlp_forces = np.append(mlp_forces, atoms.get_forces())
    mlp_virial = np.append(mlp_virial, np.array(atoms.info['virial']))

mlp_energy = np.array(mlp_energy)

if plot_fig == 1:
    figure_1 = plt.figure(figsize=(15, 3), dpi = 200)
if plot_fig == 0:
    figure_1 = plt.figure(figsize=(15, 8))

gs1 = gridspec.GridSpec(1, 3)
gs1.update(wspace=0.4)
gs1.update(hspace=0)

sp_1 = plt.subplot(gs1[0, 0])
ax=plt.gca()
ax.spines['bottom'].set_linewidth(lw2)
ax.spines['left'].set_linewidth(lw2)
ax.spines['right'].set_linewidth(lw2)
ax.spines['top'].set_linewidth(lw2)

x = dft_energy - np.mean(dft_energy)
y = mlp_energy - np.mean(dft_energy)

scale = 10

plt.xlim(-1*scale, scale)
plt.ylim(-1*scale, scale)

plt.xticks(np.arange(-scale, scale+0.01, scale/2),fontsize = fs - 6)
plt.yticks(np.arange(-scale, scale+0.01, scale/2),fontsize = fs - 6)

plt.plot(x,y, "o", color = "blue")

rmse = np.sqrt(mean_squared_error(x, y))
std = np.sqrt(np.var((x - y)**2))
plt.text(-0.01/0.045*scale, -0.038/0.045*scale, "RMSE:\n" + r" %4.2e $\pm$ %4.2e" %(rmse, std), fontsize = fs-6, color = "navy")

plt.plot([-2*scale, 2*scale], [-2*scale, 2*scale], "k--")

plt.ylabel(r"$\rm E_{MLP}$ (eV/atom)", fontsize = fs)
plt.xlabel(r"$\rm E_{PBE-D3}$ (eV/atom)", fontsize = fs)
    
sp_1 = plt.subplot(gs1[0, 1])
ax=plt.gca()
ax.spines['bottom'].set_linewidth(lw2)
ax.spines['left'].set_linewidth(lw2)
ax.spines['right'].set_linewidth(lw2)
ax.spines['top'].set_linewidth(lw2)

x = dft_forces
y = mlp_forces
plt.plot(x, y, "o", color="blue", alpha =1)

scale = 20
plt.xlim(-1*scale, scale)
plt.ylim(-1*scale, scale)
plt.xticks(np.arange(scale*(-1), scale+0.001, scale/2), fontsize = fs - 6)
plt.yticks(np.arange(scale*(-1), scale+0.001, scale/2), fontsize = fs - 6)
rmse = np.sqrt(mean_squared_error(x, y))
std = np.sqrt(np.var((x - y)**2))

plt.text(-0.01/0.045*scale, -0.038/0.045*scale, "RMSE:\n" + r" %4.2e $\pm$ %4.2e" %(rmse, std), fontsize = fs-6, color = "navy")

plt.plot([-scale, scale], [-scale, scale], color = "k", ls="--")
plt.ylabel(r"$\rm F^i_{MLP}$ (eV/$\rm \AA$)", fontsize = fs)
plt.xlabel(r"$\rm F^i_{PBE-D3}$ (eV/$\rm \AA$)", fontsize = fs)
    

sp_1 = plt.subplot(gs1[0, 2])
ax=plt.gca()
ax.spines['bottom'].set_linewidth(lw2)
ax.spines['left'].set_linewidth(lw2)
ax.spines['right'].set_linewidth(lw2)
ax.spines['top'].set_linewidth(lw2)

x = dft_virial
y = mlp_virial

x = dft_virial
y = mlp_virial

mask = ~(np.isnan(x) | np.isnan(y))  # 只保留都不是 NaN 的位置
x = x[mask]
y = y[mask]



plt.plot(x, y, "o", color="blue", label = "validation")

#plt.legend(fontsize = fs-6, edgecolor="k", framealpha=1)

scale = 200

plt.xlim(-1*scale, scale)
plt.ylim(-1*scale, scale)

plt.xticks(np.arange(-scale, scale+0.01, scale/2),fontsize = fs - 6)
plt.yticks(np.arange(-scale, scale+0.01, scale/2),fontsize = fs - 6)
rmse = np.sqrt(mean_squared_error(x, y))
mse = np.mean(x-y)
std = np.sqrt(np.var((x - y)**2))

plt.text(-0.010/0.045*scale, -0.038/0.045*scale, "RMSE:\n" + r" %4.2e $\pm$ %4.2e" %(rmse, std), fontsize = fs-6, color = "navy")

plt.plot([-2*scale, scale], [-2*scale, scale], "k--")

plt.ylabel(r"$\rm V_{MLP}$ (eV)", fontsize = fs)
plt.xlabel(r"$\rm V_{PBE-D3}$ (eV)", fontsize = fs)


if plot_fig == 1:
    plt.savefig("dpa2_error_tot.png",bbox_inches = 'tight')
if plot_fig == 0:
    plt.show()
