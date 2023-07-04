#!/bin/bash
#$ -S /bin/bash
#$ -cwd
##$ -g hp230064
#$ -l h_rt=24:00:00
#$ -l q_node=1
#$ -N run

. /etc/profile.d/modules.sh
module load cuda/11.2.146 python/3.8.3 gcc/8.3.0 cmake/3.21.3
export CC=`which gcc`
export CXX=`which g++`

GMX=/gs/hs1/hp230064/siida/gromacs-2022.5/build/bin/gmx


set -eu
tpr=npt_prod.tpr
cpt=npt_prod.cpt

#==== If the simulation described by tpr file has completed and should be extended, then
gmx convert-tpr -s $tpr -until 1000000 -o ${tpr}
gmx mdrun -deffnm npt_prod -s $tpr -cpi $cpt

#cf. https://manual.gromacs.org/current/user-guide/managing-simulations.html
