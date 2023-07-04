#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -l h_rt=00:10:00
#$ -l q_node=1
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

PDB=capped_1110.pdb #"capped_0.pdb" #$1
FF=ff14SB 

# Create Amber topology and coordinate files
pdb4amber -i $PDB --nohyd -o p4a.pdb

# Make an Amber topology
sed -e "s!#{INPUT}!p4a.pdb!g" \
    -e "s!#{FF}!${FF}!g" templates/template_tleap.in > tleap.in
tleap -f tleap.in

# Convert Amber topology and coordinate files to Gromacs ones.
python scripts/amber2gmx.py system.prmtop system.inpcrd

echo "Energy minimisation ..."
$GMX grompp -f ./templates/em.mdp \
              -c system.gro \
              -r system.gro \
              -p system.top \
              -po mdout_em.mdp \
              -o em.tpr 
$GMX mdrun -deffnm em




