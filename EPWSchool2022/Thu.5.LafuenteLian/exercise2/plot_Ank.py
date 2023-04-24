## Script to plot Ank coefficients
import matplotlib as mpl
mpl.use('pdf')
import matplotlib.pyplot as plt
import numpy as np
# change font on mathematical expressions on plots
mpl.rcParams['mathtext.fontset'] = 'cm'

# Read kpath file
kpath = np.loadtxt('path.kpt', skiprows=1)

# Read Ank file
ik, ibnd, ek0, ReAnk, ImAnk, AbsAnk = np.loadtxt('Ank.band.plrn', unpack=True, skiprows=1)


# Separate data in different bands
nbnd=np.int(max(ibnd))
maxik=np.int(max(ik))
Ak=np.zeros((maxik,nbnd))
ek=np.zeros((maxik,nbnd))
iklist=np.zeros((maxik,nbnd))
for i in range(maxik):
    for ibnd in range(nbnd):
        Ak[i][ibnd]=AbsAnk[i*nbnd+ibnd]
        ek[i][ibnd]=ek0[i*nbnd+ibnd]
        iklist[i][ibnd]=i

# Get vbm and bandwidth
vbm=max(ek[:,nbnd-1])
bandwidth=vbm-min(ek[:,0])

## Plot bands
f, ax = plt.subplots(figsize=(10,6))
ax.plot(iklist, ek, color='blue')

# Plot Ank
ax.scatter(iklist, ek, 50*Ak, color='gold', edgecolors='gray', alpha=0.8, label=r'$|A_{n\mathbf{k}}|$')

# Define high-symmetry points
W=[0.5,0.75,0.25]
L=[0.0,0.5,0.0]
G=[0.0,0.0,0.0]
X=[0.5,0.5,0.0]
K=[0.375,0.75,0.375]
sympoints=[W,L,G,X,W,K]
# Plot high-symmetry points
for i in range(len(kpath)):
    for k in sympoints:
        if (np.linalg.norm(kpath[i][0:3]-k)<1E-6):
            # Plot dashed line
            ax.plot([iklist[i][0],iklist[i][0]],[-0.1*bandwidth,bandwidth+0.1*bandwidth],'--',color='gray',linewidth=0.7)
            # Name the symmetry point
            if (k == W):
                ax.text(iklist[i][0]-3.0,-0.2*bandwidth,r'$\mathrm{W}$',fontsize=25)
            if (k == L):
                ax.text(iklist[i][0]-3.0,-0.2*bandwidth,r'$\mathrm{L}$',fontsize=25)
            if (k == G):
                ax.text(iklist[i][0]-3.0,-0.2*bandwidth,r'$\Gamma$',fontsize=25)
            if (k == X):
                ax.text(iklist[i][0]-3.0,-0.2*bandwidth,r'$\mathrm{X}$',fontsize=25)
            if (k == K):
                ax.text(iklist[i][0]-3.0,-0.2*bandwidth,r'$\mathrm{K}$',fontsize=25)
    
# Set tick params etc.
ax.set_ylim(-0.1*bandwidth,bandwidth+0.1*bandwidth)
ax.set_xlim((min(iklist[:,0]),max(iklist[:,0])))
ax.set_xticklabels([])
ax.tick_params(axis='x', color='black', labelsize='0', pad=0, length=0, width=0)  
ax.tick_params(axis='y', color='black', labelsize='18', pad=5, length=5, width=1)  
ax.set_ylabel(r'$E-E_{\mathrm{CBM}} ~ (\mathrm{eV})$', fontsize=25, labelpad=10)
ax.legend(loc='upper right', fontsize=25)

plt.savefig('Ank.pdf')
#plt.show()
