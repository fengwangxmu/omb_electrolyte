#!/bin/bash
#SBATCH -A ai4eceeg
#SBATCH -p gpu #-mig-2g-20gb
#SBATCH --qos normal
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --job-name=lammps
#SBATCH --gres=gpu:1
##SBATCH --mem=175G

set -e
source activate /public/groups/chenggroup/cxwang/conda/dp310

export OMP_NUM_THREADS=4
export TF_INTRA_OP_PARALLELISM_THREADS=2
export TF_INTER_OP_PARALLELISM_THREADS=2

set -e
