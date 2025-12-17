#set -e 
[ -f deepmd.done ] || {
    dp --pt train input.json #-f /public/home/fengw/magic/CP2K_compare_fengwang/uMLF/training/training_task/00@UMLP_DIR/original_model.pth
    dp --pt freeze -o original_model.pth
    dp --pt compress -i original_model.pth -o frozen_model.pth
    touch deepmd.done
}
