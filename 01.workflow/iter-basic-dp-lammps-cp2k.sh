#!/bin/bash

set -e

# ensure ITER_NAME is set
[ -z "$ITER_NAME" ] && echo "environment variable ITER_NAME is not set" && exit 1 || echo "ITER_NAME=$ITER_NAME"

#CONFIG_DIR=/data/fengw/proj_16_finetune/omb/redox_fc/00.init/
#WORK_DIR=/data/fengw/proj_16_finetune/omb/redox_fc/02.workdir
#
#NUMBER_NEWDATA=1
#LAMMPS_STEPS=1000

# create iter dir
ITER_DIR=$WORK_DIR/iter-$ITER_NAME                                                             
mkdir -p $ITER_DIR

[ -f $ITER_DIR/iter.done ] && echo "iteration $ITER_NAME already done" && exit 0 || echo "starting iteration at $ITER_DIR"

# step 1: training


DP_DIR=$ITER_DIR/deepmd

[ -f $DP_DIR/setup.done ] && echo "skip deepmd setup" || {
    omb combo \
        add_seq MODEL_ID 0 4 - \
        add_randint SEED -n 4 -a 100000 -b 999999 --uniq - \
        set_broadcast SEED - \
        add_var UMLP_DIR  0 1 2 3 - \
        set_broadcast UMLP_DIR - \
        add_file_set DP_DATASET "$CONFIG_DIR/00.init_data/*/" "$WORK_DIR/iter-*/new-dataset/*" --format json-item --abs - \
        make_files $DP_DIR/model-{MODEL_ID}/input.json --template $CONFIG_DIR/01.deepmd/input.json - \
        make_files $DP_DIR/model-{MODEL_ID}/run.sh     --template $CONFIG_DIR/01.deepmd/dp-run.sh  --mode 755 - \
        done

    omb batch \
        add_work_dirs "$DP_DIR/model-*" - \
        add_header_files $CONFIG_DIR/slurm-header/slurm-dp-header.sh  - \
        add_cmds "bash ./run.sh" - \
        make $DP_DIR/dp-train-{i}.slurm  --concurrency 4

    touch $DP_DIR/setup.done
}

omb job slurm submit \
    "$DP_DIR/dp-train"*.slurm \
    --max_tries 2 \
    --wait \
    --recovery "$DP_DIR/slurm-recovery.json"


# step 2: explore
LMP_DIR=$ITER_DIR/lammps
mkdir -p $LMP_DIR

[ -f $LMP_DIR/setup.done ] && echo "skip lammps setup" || {
    omb combo \
        add_var STEPS $LAMMPS_STEPS - \
        add_var FREQ 50 - \
        add_var TEMP 300 350 400 450 500 550 600 - \
        set_broadcast TEMP - \
        add_files DATA_FILE "$CONFIG_DIR/02.explore/conf-*.lmp" --abs - \
        add_file_set DP_MODELS "$DP_DIR/model-*/frozen_model.pth" --abs - \
        make_files $LMP_DIR/job-{TEMP}K-{i:03d}/lammps.in --template $CONFIG_DIR/03.lammps/lammps.in - \
        make_files $LMP_DIR/job-{TEMP}K-{i:03d}/run.sh    --template $CONFIG_DIR/03.lammps/lmp-run.sh --mode 755 - \
        done

    omb batch \
        add_work_dirs "$LMP_DIR/job-*" - \
        add_header_files $CONFIG_DIR/slurm-header/slurm-lammps-header.sh  - \
        add_cmds "bash ./run.sh" - \
        make $LMP_DIR/lammps-{i}.slurm  --concurrency 10

    touch $LMP_DIR/setup.done
}

omb job slurm submit "$LMP_DIR/lammps*.slurm" --max_tries 2 --wait --recovery $LMP_DIR/slurm-recovery.json

# step 3: screening
SCREENING_DIR=$ITER_DIR/screening
mkdir -p $SCREENING_DIR

[ -f $SCREENING_DIR/screening.done ] && echo "skip screening" || {

    ai2-kit tool model_devi - \
        read "$LMP_DIR/job-*/" --traj_file mlmd.lammpstrj --md_file model_devi.out --ignore_error - \
        slice ":" - \
        grade --lo 0.2 --hi 0.3 --col max_devi_f - \
        dump_stats $SCREENING_DIR/stats.tsv - \
        write $SCREENING_DIR/candidate.xyz --level decent - \
        done

    cat $SCREENING_DIR/stats.tsv 
    touch $SCREENING_DIR/screening.done
}


# step 4: labeling
LABELING_DIR=$ITER_DIR/cp2k
mkdir -p $LABELING_DIR

[ -f $LABELING_DIR/setup.done ] && echo "skip cp2k setup" || {
    # pick 10 frames from the candidate.xyz
    ai2-kit tool ase read $SCREENING_DIR/candidate.xyz - sample $NUMBER_NEWDATA  - \
        write_frames $LABELING_DIR/data/{i:03d}.inc --format cp2k-inc

    omb combo \
        add_files DATA_FILE "$LABELING_DIR/data/*" --abs -\
        make_files $LABELING_DIR/job-{i:03d}/input.inp --template $CONFIG_DIR/04.cp2k/input.inp - \
        make_files $LABELING_DIR/job-{i:03d}/run.sh    --template $CONFIG_DIR/04.cp2k/cp2k-run.sh --mode 755 - \
        done

    omb batch \
        add_work_dirs "$LABELING_DIR/job-*" - \
        add_header_files $CONFIG_DIR/slurm-header/slurm-cp2k-header.sh - \
        add_cmds "bash ./run.sh" - \
        make $LABELING_DIR/cp2k-{i}.slurm  --concurrency 5

    touch $LABELING_DIR/setup.done
}

omb job slurm submit "$LABELING_DIR/cp2k*.slurm" --max_tries 2 --wait --recovery "$LABELING_DIR/slurm-recovery.json"

ai2-kit tool dpdata read $LABELING_DIR/job-*/output --fmt='cp2k/output' --ignore_error  - write $ITER_DIR/new-dataset/

touch $ITER_DIR/iter.done                                                                                                              

