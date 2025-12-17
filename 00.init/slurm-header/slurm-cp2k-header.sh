#!/bin/bash
#SBATCH -A ai4eceeg
#SBATCH -p cpu
#SBATCH --qos normal
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=64
#SBATCH -J cp2k

module load cp2k/2024.3
##############################################
#               Run job                      #
##############################################
export OMPI_MCA_btl_openib_allow_ib=1
