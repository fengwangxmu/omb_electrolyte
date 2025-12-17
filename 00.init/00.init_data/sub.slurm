#!/bin/bash -l
#SBATCH -A ai4eceeg
#SBATCH -p gpu
#SBATCH --qos normal
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --job-name=TBD
#SBATCH --gres=gpu:1


source activate /public/groups/chenggroup/cxwang/conda/dp310
export OMP_NUM_THREADS=4
export TF_INTRA_OP_PARALLELISM_THREADS=2
export TF_INTER_OP_PARALLELISM_THREADS=2

#lmp_mpi -i input_mlmd.lammps -v restart 0

rm *xyz
#dp --tf compress -i graph.000.pb -o graph.000.compress.pb
python ./sys2xyz.py
cat *xyz > out.xyz
python get_dp_energy_force.py

#dp --pt change-bias original_model.pth -s "../datasets_IrO2/O743Ir180H767O11_Oradical" -o original_model_zero_mse_oh_radical.pth
#dp --pt change-bias original_model.pth -s "/public/home/fengw/SrIrO3_IrO2/free_energy/01.IrO2_H2O_to_OH_radical/label_OH_radical/iter-002/ini/O744Ir180H768" -o original_model_zero_mse_h2o.pth
#dp --pt compress -i original_model_zero_mse_oh_radical.pth -o frozen_model_zero_mse_oh_radical.pth -t out.json
#dp --pt compress -i original_model_zero_mse_h2o.pth        -o frozen_model_zero_mse_h2o.pth -t out.json

