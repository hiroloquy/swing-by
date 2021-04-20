# Setting --------------------
reset
set nokey
set term gif animate delay 4 size 1280,720
set grid
L    = 15e7
set xr[-L:L]
set yr[-L:L]
set xl "{/Times:Italic x} [m]" font "Times New Roman, 20"
set yl "{/Times:Italic y} [m]" font "Times New Roman, 20"
set size ratio -1

# Parameter --------------------
G    =    6.674 * 1e-11              # gravitational constant    [m3 / kg s2]
R    =    6.371 * 1e6                # radius of the earth       [m]
M    =    5.972 * 1e24               # weight of the earth       [kg]
r    =    1.737 * 1e6                # radius of the moon        [m]
m    =    7.348 * 1e0                # weight of the moon        [kg]

dt    =    10                        # Time step                 [s]
v2    =    0.2*sqrt(2*G*M/R)         # Second cosmic velocity
dh    =    dt/6.0                    # Coefficient for Runge-Kutta 4th

lim1    = 30                         # Stop time
lim2    = 1000                       # Time limit

dis        = 200                     # Start to disappear
cut        = 5                       # Decimation

# Function --------------------
# Runge-Kutta 4th order method
r(x, y, z, w)  = (sqrt(x**2 + z**2))**3
f1(x, y, z, w) = y
f2(x, y, z, w) = -G * M * x / r(x, y, z, w)
f3(x, y, z, w) = w
f4(x, y, z, w) = -G * M * z / r(x, y, z, w)
 
rk4x(x, y, z, w) = (k1 = f1(x, y, z, w),\
                    k2 = f1(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k3 = f1(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k4 = f1(x + dt*k3, y + dt*k3, z + dt*k3, w + dt*k3),\
                    dh * (k1 + 2*k2 + 2*k3 + k4))
rk4y(x, y, z, w) = (k1 = f2(x, y, z, w),\
                    k2 = f2(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k3 = f2(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k4 = f2(x + dt*k3, y + dt*k3, z + dt*k3, w + dt*k3),\
                    dh * (k1 + 2*k2 + 2*k3 + k4))
rk4z(x, y, z, w) = (k1 = f3(x, y, z, w),\
                    k2 = f3(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k3 = f3(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k4 = f3(x + dt*k3, y + dt*k3, z + dt*k3, w + dt*k3),\
                    dh * (k1 + 2*k2 + 2*k3 + k4))
rk4w(x, y, z, w) = (k1 = f4(x, y, z, w),\
                    k2 = f4(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k3 = f4(x + dt*k1/2., y + dt*k1/2., z + dt*k1/2., w + dt*k1/2.),\
                    k4 = f4(x + dt*k3, y + dt*k3, z + dt*k3, w + dt*k3),\
                    dh * (k1 + 2*k2 + 2*k3 + k4))

# Time
Time(t) = sprintf("{/Times:Italic t} = %d [s]", t)

# Parameter
Para(th) = sprintf("{/Times:Normal=20 {/Symbol-Oblique:Italic q} = %d", th)

# Plot --------------------
# Initiate value
t    = 0.0
th    = 60
rad = pi/180.*th

# Earth
ve    = 10000.
xe    = 0.8e7

# Filename
filename = sprintf("swingby ve=%+d th=%02d.gif", ve, th)
set output filename

# Satellite 1
x1    =    0.                  # x
y1    =    v2*cos(rad)         # vx
z1    =    13e7                # y
w1    =    -v2*sin(rad)        # vy

# Satellite 2
x2    =    0.                  # x
y2    =    v2*cos(rad)         # vx
z2    =    12e7                # y
w2    =    -v2*sin(rad)        # vy

# Satellite 3
x3    =    0.                  # x
y3    =    v2*cos(rad)         # vx
z3    =    11e7                # y
w3    =    -v2*sin(rad)        # vy

# Draw inititate state for lim1 steps
do for [i = 1:lim1] {
    # Time and parameter
    set title Time(t) font 'Times:Normal, 22'
    set label 1 left at graph 0.05, graph 0.95 Para(th)

    # Earth
    set object 1 circle at xe, 0 fc rgb 'skyblue' size R fs solid

    # Satellite
    set object 2 circle at x1, z1 fc rgb 'red' size r fs solid
    set object 3 circle at x2, z2 fc rgb 'blue' size r fs solid
    set object 4 circle at x3, z3 fc rgb 'green' size r fs solid

    plot 1/0
}

# Update for lim2 steps
do for [i = 1:lim2] {
    t    = t + dt

    # Earth
    xe    = xe + ve*dt
    set object 1 at xe, 0

    # Calculate using RK4
    x1 = x1 + rk4x(x1-xe, y1, z1, w1)
    y1 = y1 + rk4y(x1-xe, y1, z1, w1)
    z1 = z1 + rk4z(x1-xe, y1, z1, w1)
    w1 = w1 + rk4w(x1-xe, y1, z1, w1)

    x2 = x2 + rk4x(x2-xe, y2, z2, w2)
    y2 = y2 + rk4y(x2-xe, y2, z2, w2)
    z2 = z2 + rk4z(x2-xe, y2, z2, w2)
    w2 = w2 + rk4w(x2-xe, y2, z2, w2)

    x3 = x3 + rk4x(x3-xe, y3, z3, w3)
    y3 = y3 + rk4y(x3-xe, y3, z3, w3)
    z3 = z3 + rk4z(x3-xe, y3, z3, w3)
    w3 = w3 + rk4w(x3-xe, y3, z3, w3)

    # Satellite 1 (Old object turns smaller)
    set object 3*i+2 circle at x1, z1 fc rgb 'red' size r fs solid
    set object 3*(i-1)+2 circle size r/1e5 fs solid

    # Satellite  (Old object turns smaller)
    set object 3*i+3 circle at x2, z2 fc rgb 'blue' size r fs solid
    set object 3*(i-1)+3 circle size r/1e5 fs solid

    # Satellite 3 (Old object turns smaller)
    set object 3*i+4 circle at x3, z3 fc rgb 'green' size r fs solid
    set object 3*(i-1)+4 circle size r/1e5 fs solid

    # Remove old objects
    if(i>=dis){
        unset object 3*(i-dis)+2
        unset object 3*(i-dis)+3
        unset object 3*(i-dis)+4
    }

    # Time
    set title Time(t)

    # Decimate and plot
    if(i%cut==0){
        plot 1/0
    }
}

set out