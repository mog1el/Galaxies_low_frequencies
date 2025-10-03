import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('output.csv', header=None)
df.columns = ['hpz', 'hxz']

###
total_time = 1e1
dt = 0.00005
Nbinmin = 10
Nbinmax = 1000
Nchunks = 15 # Number of chunks
###

time = [i * dt for i in range(int(len(df)))]
Nbin = [i for i in range(Nbinmax + 1)]

data1 = df['hpz']
data2 = df['hxz']
#data3 = df['hpx']
#data4 = df['hxx']

#print(data1, data2, data3, data4)

fig = plt.figure()
ax = fig.add_subplot(projection='3d')

later = total_time/(dt * Nchunks)

for i in Nbin:
    if i >= 10:
        ax.plot(time, i, data1[(i-10)*later:(i-10)*later+later-1])
        ax.plot(time, i, data2[(i-10)*later:(i-10)*later+later-1])
        
ax.set_xlabel('t[years]')
ax.set_ylabel('X')
ax.set_zlabel('Z')

ax.view_init(elev=20., azim=-35, roll=0)
ax.legend()

plt.grid(True)
plt.show()