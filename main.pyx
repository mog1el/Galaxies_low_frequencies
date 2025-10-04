import numpy as np
import csv
import random

Mpc = 5.38552341e20

G = 6.6743e-11
c = 299792458
Msun = 1.989e30
min_mass = 1e5 * Msun # Value in log
max_mass = 1e10 * Msun # Value in log
star_radius = 14000

class Particle():
    def __init__(self, x, y, r, density, radius, color, omega):
        self.x = x
        self.y = y
        self.r = r
        self.density = density
        self.radius = radius
        self.mass = density * (4/3) * np.pi * radius ** 3
        self.color = color
        self.omega = omega

        self.x_vel = 0
        self.y_vel = 0

def gravity(particles, G, dt):
    if len(particles) == 2:
        p1 = particles[0]
        p2 = particles[1]

        dx = p1.x - p2.x
        dy = p1.y - p2.y

        dist2 = dx**2 + dy**2
        dist = np.sqrt(dist2)
        if dist < p1.radius + p2.radius:
            return True
        F = (G * p1.mass * p2.mass) / dist2
        Fx = F * dx / dist
        Fy = F * dy / dist

        p1.x_vel -= Fx / p1.mass * dt
        p1.y_vel -= Fy / p1.mass * dt

        p2.x_vel += Fx / p2.mass * dt
        p2.y_vel += Fy / p2.mass * dt

        LGW = (32 * G ** 4 * (p1.mass + p2.mass) ** 3 * ((p1.mass * p2.mass)/(p1.mass + p2.mass))** 2)/(5 * c ** 5 * (dist/2) ** 5)
        
        Eloss = LGW * dt
        Ecurr = -G * p1.mass * p2.mass / (dist)
        ENew = Ecurr - Eloss
        rnew = -G * p1.mass * p2.mass / (2 * ENew)
        scale = rnew /(dist/2)
        #print(scale)     
        p1.x = masscentrx + (p1.x - masscentrx) * scale
        p1.y = masscentry + (p1.y - masscentry) * scale

        p2.x = masscentrx + (p2.x - masscentrx) * scale
        p2.y = masscentry + (p2.y - masscentry) * scale

        scalev = 1 / np.sqrt(scale)
        #print(scalev)
        p1.x_vel *= scalev
        p1.y_vel *= scalev
        p2.x_vel *= scalev
        p2.y_vel *= scalev

        p1.omega = np.sqrt(G * (p1.mass + p2.mass) / (dist/2)**3)
        p2.omega = p1.omega

    return False

masscentrx = 0
masscentry = 0

def GW(omega, t, R, r, m):
    Amp = (8 * m * omega ** 2 * R ** 2)/r 
    hplusz = -Amp * np.cos(2 * omega * t)
    #hplusx = hplusz/2
    #hxz = Amp * np.sin(2 * omega * t)
    #hxx = hxz/2
    return hplusz#, hxz, hplusx, hxx

def datacol(my_particles, data1, dt, chunks):
    t = 0
    j = 0

    running = True
    while running and j < chunks:
        if gravity(my_particles, G, dt):
            running = False

        star1 = my_particles[0]
        hpz = GW(star1.omega, t, (star1.x - masscentrx), star1.r, star1.mass)
        data1[j] += hpz ** 2
        #data2[j] += hxz ** 2
        #data3[j] += hpx ** 2
        #data4[j] += hxx ** 2

        for p in my_particles:
            p.x += p.x_vel * dt
            p.y += p.y_vel * dt
        
        t += dt
        j += 1
    return data1#, data2, data3, data4

print("Setup done")

def letsgo(total_time=1e4, dt=5e-3, Nbinmin = 10, Nbinmax = 1000, R = 40, Nchunks = 1):
    RhoGalaxies = 1/(100 * Mpc ** 3)
    R = R * Mpc
    chunks = int((total_time/dt)/Nchunks)
    for Nbin in range(Nbinmin, Nbinmax + 1):
        filename = f'outputs/output_{Nbin}.csv'
        print(f"Starting simulation with {Nbin} galaxies per black hole binary")
        NGalaxies = int(RhoGalaxies * (4/3) * np.pi * R ** 3)
        print(f"Number of galaxies: {NGalaxies}")
        NBlackHoles = int(NGalaxies / Nbin)
        print(f"Number of black hole binaries: {NBlackHoles}")
        iter = NBlackHoles
    
        print("Creating black holes")
    
        total_particles = []
        for i in range(iter):
            Mlog = random.uniform(np.log10(min_mass), np.log10(max_mass))
            M = 10 ** Mlog
            T = random.uniform(1 * 24 * 3600, 2 * 24 * 3600)
            dist0 = ((T ** 2 * G * 2 * M) / (2 * np.pi ** 2))**(1/3)
            theta = random.uniform(0, 2 * np.pi)
            d_obs = random.uniform(0, R)
    
            star1 = Particle(-np.sin(theta) * (dist0/2), np.cos(theta) * (dist0/2), d_obs, (M * 3)/(4 * np.pi * star_radius ** 3), star_radius, (255, 255, 255), 0)
            star2 = Particle(-star1.x, -star1.y, d_obs, (M * 3)/(4 * np.pi * star_radius ** 3), star_radius, (255, 255, 255), 0)
        
            v0 = np.sqrt((G * star1.mass) / (4 * (dist0)/2))
    
            star1.x_vel = -v0 * np.cos(theta)
            star1.y_vel = v0 * np.sin(theta)
    
            star2.x_vel = -star1.x_vel
            star2.y_vel = -star1.y_vel
    
            my_particles = [star1, star2]
            total_particles.append(my_particles)
            if i % 1000000 == 0:
                print(f"{i}/{iter}")
    
        print("Black holes created")
        print("Starting simulation")
    
        with open(filename, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            for i in range(Nchunks):
                print(f"Starting chunk {i+1}")
                data1 = [0.0] * chunks
                #data2 = [0.0] * chunks
                #data3 = [0.0] * chunks
                #data4 = [0.0] * chunks
                for j in range(0, NBlackHoles):
                    print(f"Starting black holes {j+1}/{NBlackHoles}")
                    data1 = datacol(total_particles[j], data1, dt, chunks)
                for i in range(len(data1)):
                    data1[i] = np.sqrt(data1[i])
                    #data2[i] = np.sqrt(data2[i])
                    #data3[i] = np.sqrt(data3[i])
                    #data4[i] = np.sqrt(data4[i])
                df = zip(data1)
                print("Outputting data")
                writer.writerows(df)
    
    print("All done")