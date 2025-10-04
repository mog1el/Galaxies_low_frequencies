import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

###
total_time = 1e2
dt = 0.005
Nbinmin = 10
Nbinmax = 1000
Nchunks = 15 # Number of chunks
###
def plotting(show=False, outputfile='Figure.png', total_time=1e4, dt=5e-3, Nbinmin = 10, Nbinmax = 1000):
    time = [i * dt for i in range(int(total_time/dt))]
    Nbin = [i for i in range(Nbinmax + 1)]

    fig = plt.figure()
    ax = fig.add_subplot(projection='3d')

    later = total_time/(dt * Nchunks)

    for i in Nbin:
        if i >= Nbinmin:
            df = pd.read_csv(f'outputs/output_{i}.csv', header=None)
            df.columns = ['hpz']
            data1 = df['hpz']
            ax.plot(time, np.full_like(time, i), data1)

    ax.set_xlabel('t[years]')
    ax.set_ylabel('Nbin')
    ax.set_zlabel('h(Z)')

    #ax.set_zlim(0, 0.5e38)
    ax.view_init(elev=20., azim=-35, roll=0)
    ax.legend()

    plt.grid(True)
    if show:
        plt.show()
    plt.savefig(outputfile, bbox_inches='tight')