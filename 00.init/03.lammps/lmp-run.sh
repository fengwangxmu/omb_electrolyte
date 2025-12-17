#set -e 
[ -f lammps.done ] || {
    lmp_mpi -i lammps.in -v restart 0
    touch lammps.done
}
