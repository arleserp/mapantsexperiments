# Import libraries
from mpl_toolkits import mplot3d
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
import scipy.interpolate as interp
from scipy.interpolate import griddata
import sys

def load_world_data(filename):
    with open("gradient_rep/"+filename) as f:
        data = f.readlines()
    i = 0
    j = 0
    for line in data:
        if "PATCHES" in line:
            break
        else:
            i += 1

    for line in data:
        if "LINKS" in line:
            break
        else:
            j += 1

    x = []
    y = []
    z = []
    for iter in range(i+2, j-1):                    
        sp = data[iter].split(",")
        x.append(float(sp[0].replace('"', '')))
        y.append(float(sp[1].replace('"', '')))
        z.append(float(sp[5].replace('"', '')))
    #print(x[1], y[1], z[1])
    x = np.array(x)
    y = np.array(y)
    z = np.array(z)

    xv = np.linspace(np.min(x), np.max(x), 100)
    yv = np.linspace(np.min(y), np.max(y), 100)
    [X,Y] = np.meshgrid(xv, yv)
    Z = griddata((x,y),z,(X,Y),method='linear')
    return X, Y, Z

def plot_contour(x, y, z):
    
    # Creating color map
    my_cmap = plt.get_cmap('hot')

    # Creating plot
    fig, ax = plt.subplots(1, 1) 

    cp = ax.contour(x, y, z, colors='black', linestyles='dashed', linewidths=1)   
    ax.clabel(cp, inline=1, fontsize=10)
    cp = plt.contourf(x, y, z, )
    ax.set_title('Contour Plot') 

    # show plot
    plt.show()

def gradient_descent(W, x, y):
    y_hat = x.dot(W).flatten()
    error = (y - y_hat)
    mse = (1.0 / len(x)) * np.sum(np.square(error))
    gradient = -(1.0 / len(x)) * error.dot(x)
    return gradient, mse

def plot_gradient():
    w = np.array((-40, -40))
    alpha = .1
    tolerance = 1e-3
    
    old_w = []
    errors = []

    # Perform Gradient Descent
    iterations = 1
    for i in range(200):
        gradient, error = gradient_descent(w, X_scaled, y)
        new_w = w - alpha * gradient
 
        # Print error every 10 iterations
        if iterations % 10 == 0:
            print("Iteration: %d - Error: %.4f" % (iterations, error))
            old_w.append(new_w)
            errors.append(error)
    
        # Stopping Condition
        if np.sum(abs(new_w - w)) < tolerance:
            print('Gradient Descent has converged')
            break
    
        iterations += 1
        w = new_w
 
    print('w =', w)

def plot_data(x, y, z):
    # Creating dataset
    #x = np.outer(np.linspace(-3, 3, 32), np.ones(32))
    #y = x.copy().T # transpose
    #z = (np.sin(x **2) + np.cos(y **2) )

    # Creating figure
    fig = plt.figure(figsize =(14, 9))
    ax = plt.axes();#projection ='3d')


    '''surf = ax.plot_surface(x, y, z, 
                        rstride = 8,
                        cstride = 8,
                        facecolors=cm.jet(N),
                        alpha = 0.8)
                        #cmap = my_cmap)
    '''
    '''cset = ax.contourf(x, y, z,
                    zdir ='z',
                    offset = np.min(z),
                    cmap = my_cmap)
    cset = ax.contourf(x, y, z,
                    zdir ='x',
                    offset =-5,
                    cmap = my_cmap)
    cset = ax.contourf(x, y, z, 
                    zdir ='y',
                    offset = 5,
                    cmap = my_cmap)
    fig.colorbar(surf, ax = ax, 
                shrink = 0.5,
                aspect = 5)'''

    cp = plt.contourf(x, y, z)
    cb = plt.colorbar(cp)
    
    # Creating color map
    my_cmap = plt.get_cmap('hot')
    dfdy, dffx = np.gradient(z) # gradients with respect to x and y
    #G = (Gx**2+Gy**2)**.5  # gradient magnitude https://stackoverflow.com/questions/6539944/color-matplotlib-plot-surface-command-with-surface-gradient
    # Creating plot
    #N = G/G.max()  # normalize 0..1    
    plt.quiver(x[5::10,5::10], y[5::10,5::10], dffx[5::10,5::10], dfdy[5::10,5::10], pivot="middle")
    #plt.quiver(x[5::5,5::5], y[5::5,5::5], dffx[5::5,5::5], dfdy[5::5,5::5], pivot="middle")
    # Adding labels
    '''ax.set_xlabel('X-axis')
    ax.set_xlim(-10, 10)
    ax.set_ylabel('Y-axis')
    ax.set_ylim(-10, 10)'''
    #ax.set_zlabel('Z-axis')
    #ax.set_zlim(np.min(z), np.max(z))
    #ax.set_title('3D surface having 2D contour plot projections')

    # show plot
    plt.show()

def main():
	args = sys.argv[1:]
	x, y, z = load_world_data(args[0])
	plot_data(x, y, z)
#plot_contour(x, y, z)

main()