set -e

[ -f cp2k.done ] || {
    mpirun  cp2k.popt input.inp >& output  || true
    touch cp2k.done
}

