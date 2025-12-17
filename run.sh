#!/bin/bash
set -e

export CONFIG_DIR=${PWD}/00.init/
export WORK_DIR=${PWD}/02.workdir
export NUMBER_NEWDATA=100
export LAMMPS_STEPS=20000


ITER_NAME="000" ./01.workflow/iter-basic-dp-lammps-cp2k.sh
ITER_NAME="001" ./01.workflow/iter-basic-dp-lammps-cp2k.sh
ITER_NAME="002" ./01.workflow/iter-basic-dp-lammps-cp2k.sh
ITER_NAME="003" ./01.workflow/iter-basic-dp-lammps-cp2k.sh
ITER_NAME="004" ./01.workflow/iter-basic-dp-lammps-cp2k.sh

