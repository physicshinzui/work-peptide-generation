#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l h_rt=00:10:00
#$ -l f_node=1
##$ -g hp230064
#$ -N run
set -eu

. /etc/profile.d/modules.sh
#module load cuda/11.2.146 python/3.11.2 gcc/10.2.0 gromacs/2023
module load cuda/11.2.146 python/3.8.3 gcc/8.3.0 cmake/3.21.3
export CC=`which gcc`
export CXX=`which g++`

. ~/.bashrc
conda activate ambertools

GMX=/gs/hs1/hp230064/siida/gromacs-2022.5/build/bin/gmx

set -eu
#===========Production run=====================
echo "NPT runs are running..."
cp ./templates/npt_prod.mdp npt_prod.mdp
$GMX grompp -f npt_prod.mdp  \
            -c em.gro    \
            -p system.top \
            -po mdout_npt_prod.mdp \
            -o npt_prod.tpr

$GMX mdrun -deffnm npt_prod #-ntomp $OMP_NUM_THREADS -ntmpi $NUM_MPI
