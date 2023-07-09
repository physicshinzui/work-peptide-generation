#!/bin/bash

. /etc/profile.d/modules.sh
module load cuda/11.2.146 python/3.8.3 gcc/8.3.0 cmake/3.21.3
export CC=`which gcc`
export CXX=`which g++`

. ~/.bashrc
conda activate ambertools

GMX=/gs/hs1/hp230064/siida/gromacs-2022.5/build_gpu/bin/gmx

PDB=$1
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
$GMX mdrun -deffnm em -ntomp 14 -ntmpi 1

#===========Production run=====================
echo "NPT runs are running..."
sed -e "s/#{RAND}/$RANDOM/g" ./templates/npt_prod.mdp > npt_prod.mdp
$GMX grompp -f npt_prod.mdp  \
            -c em.gro    \
            -p system.top \
            -po mdout_npt_prod.mdp \
            -o npt_prod.tpr \
            -maxwarn 1

$GMX mdrun -deffnm npt_prod -nsteps 500000 -ntomp 14 -ntmpi 1
