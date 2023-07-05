import MDAnalysis as mda
from MDAnalysis.analysis.dihedrals import Dihedral
from MDAnalysis.analysis.dihedrals import Ramachandran
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import sys

top = sys.argv[1]
xtc = sys.argv[2]
u = mda.Universe(top, xtc)

r = u.select_atoms("resid 2-3")

R = Ramachandran(r).run()
print(R.results.angles)
phi, psi = R.results.angles[:, 0][:, 0], R.results.angles[:, 0][:, 1]

# Plot the heatmap using Seaborn
plt.plot(phi, psi, alpha=0.1, ls='', marker='o', c='black', markersize=1)
sns.kdeplot(x=phi, y=psi, cmap="Spectral", shade=False, bw_adjust=.5)

plt.xlim(-180, 180)
plt.ylim(-180, 180)

plt.show()
plt.savefig("rama.png")
