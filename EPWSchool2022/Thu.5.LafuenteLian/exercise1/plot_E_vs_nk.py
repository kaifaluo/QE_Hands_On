import matplotlib as mpl
mpl.use('pdf')
import matplotlib.pyplot as plt
from matplotlib.ticker import MultipleLocator,FormatStrFormatter
import numpy as np

# Read E vs nk
Nk, Eform = np.genfromtxt('E_vs_nk.dat', unpack=True)

# Set unit cell volume to convert Nk to inverse supercell size
ucell_volume = 112.8044

# Start figure
fig, ax = plt.subplots(figsize=(12,8))

# Plot Eform
ax.scatter(1/(Nk*ucell_volume**(1/3)), Eform, s=50, marker='o', color='darkred', edgecolors='black')

# Perform linear fit and plot
mf, bf = np.polyfit(1/(Nk*ucell_volume**(1/3)), Eform, 1)
xlist = np.linspace(0.0, np.max(1/(Nk*ucell_volume**(1/3))), 100)
print("Extrapolation to isolated polaron formation energy = ", "%.3f" % bf, "eV")
ax.plot(xlist, mf*xlist+bf, '--', color='gray')

# Set tick params etc.
ax.set_xlabel(r'Inverse supercell size ($\mathrm{bohr}^{-1}$)',fontsize=20)
ax.set_ylabel('Formation energy (eV)',fontsize=20, labelpad=5)
ax.tick_params(axis='x', color='black', labelsize='20', pad=5, length=5, width=2)
ax.tick_params(axis='y', color='black', labelsize='20', pad=5, length=5, width=2, right=True)
ax.yaxis.set_minor_locator(MultipleLocator(0.1))
ax.tick_params(axis='y', which='minor', color='black', labelsize='20', pad=5, length=3, width=1.2, right=True)
ax.set_xlim(0.0, np.max(1/(Nk*ucell_volume**(1/3)))+0.01)
ax.set_title('LiF hole polaron', fontsize=20)

plt.savefig("E_vs_nk.pdf")
#plt.show()
