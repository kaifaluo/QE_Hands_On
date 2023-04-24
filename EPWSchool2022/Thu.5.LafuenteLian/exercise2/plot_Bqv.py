## Script to plot Bqv coefficients
import matplotlib as mpl
mpl.use('pdf')
import matplotlib.pyplot as plt
import numpy as np
# change font on mathematical expressions on plots
mpl.rcParams['mathtext.fontset'] = 'cm'

# Read kpath file
qpath = np.loadtxt('path.kpt', skiprows=1)

# Read Bqv file
iq, imode, wq0, ReBqv, ImBqv, AbsBqv = np.loadtxt('Bmat.band.plrn', unpack=True, skiprows=1)

# Separate data in different bands
nmodes=np.int(max(imode))
maxiq=np.int(max(iq))
Bq=np.zeros((maxiq,nmodes))
wq=np.zeros((maxiq,nmodes))
iqlist=np.zeros((maxiq,nmodes))
for i in range(maxiq):
    for imode in range(nmodes):
        Bq[i][imode]=AbsBqv[i*nmodes+imode]
        wq[i][imode]=wq0[i*nmodes+imode]
        iqlist[i][imode]=i

# Get max w
wmax=max(wq[:,nmodes-1])

## Plot phonon bands
f, ax = plt.subplots(figsize=(10,6))
ax.plot(iqlist, wq, color='blue')

# Plot Bqv
ax.scatter(iqlist, wq, 10*Bq, color='gold', edgecolors='gray', alpha=0.8, label=r'$|B_{\mathbf{q}\nu}|$')

# Define high-symmetry points
W=[0.5,0.75,0.25]
L=[0.0,0.5,0.0]
G=[0.0,0.0,0.0]
X=[0.5,0.5,0.0]
K=[0.375,0.75,0.375]
sympoints=[W,L,G,X,W,K]
# Plot high-symmetry points
for i in range(len(qpath)):
    for k in sympoints:
        if (np.linalg.norm(qpath[i][0:3]-k)<1E-6):
            # Plot dashed line
            ax.plot([iqlist[i][0],iqlist[i][0]],[0.0,wmax+0.1*wmax],'--',color='gray',linewidth=0.7)
            # Name the symmetry point
            if (k == W):
                ax.text(iqlist[i][0]-3.0,-0.1*wmax,r'$\mathrm{W}$',fontsize=25)
            if (k == L):
                ax.text(iqlist[i][0]-3.0,-0.1*wmax,r'$\mathrm{L}$',fontsize=25)
            if (k == G):
                ax.text(iqlist[i][0]-3.0,-0.1*wmax,r'$\Gamma$',fontsize=25)
            if (k == X):
                ax.text(iqlist[i][0]-3.0,-0.1*wmax,r'$\mathrm{X}$',fontsize=25)
            if (k == K):
                ax.text(iqlist[i][0]-3.0,-0.1*wmax,r'$\mathrm{K}$',fontsize=25)
    
# Set tick params etc.
ax.set_ylim(0.0,wmax+0.1*wmax)
ax.set_xlim((min(iqlist[:,0]),max(iqlist[:,0])))
ax.set_xticklabels([])
ax.tick_params(axis='x', color='black', labelsize='0', pad=0, length=0, width=0)  
ax.tick_params(axis='y', color='black', labelsize='18', pad=5, length=5, width=1)  
ax.set_ylabel(r'$\omega_{\mathbf{q}\nu} ~ (\mathrm{meV})$', fontsize=25, labelpad=10)
ax.legend(loc='upper right', fontsize=25)

plt.savefig('Bqv.pdf')
#plt.show()
