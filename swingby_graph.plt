# Setting --------------------
reset
set key right top
set term gif animate delay 4 size 1280,720
set grid
end = 1e3*10
set xr[0:end]
set yr[0:5*1e3]
set xl "{/Times:Italic t} [s]" font "Times New Roman, 20"
set yl "{/Times:Italic v} [m/s]" font "Times New Roman, 20"
set size ratio 720./1280.

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
lim2    = end/dt                     # Time limit

dis        = 200                     # Start to disappear
cut        = 5                       # Decimation

# Function --------------------
# RK4
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
t = 0.0
th = 60
rad = pi/180.*th

# Earth
ve = 10000.
xe = 0.8e7

# Filename
filename = sprintf("graph ve=%+0d th=%02d.gif", ve, th)
set output filename

# Satellite 1
x1 = 0.                                # x
y1 = v2*cos(rad)                       # vx
z1 = 13e7                              # y
w1 = -v2*sin(rad)                      # vy

# Satellite 2
x2 = 0.                                # x
y2 = v2*cos(rad)                       # vx
z2 = 12e7                              # y
w2 = -v2*sin(rad)                      # vy

# Satellite 3
x3 = 0.                                # x
y3 = v2*cos(rad)                       # vx
z3 = 11e7                              # y
w3 = -v2*sin(rad)                      # vy

# Draw initiate state for lim1 steps
do for [i = 1:lim1] {
 # Parameter and v2 line
 set label 1 left at graph 0.05, graph 0.95 Para(th)
 set arrow 1 nohead from 0, v2 to end, v2 lc rgb 'black' lw 4

 # Display key
 plot 1/0 lw 3 lc rgb 'red' t "{/Times:Italic=20 v_{1}}  ",\
   1/0 lw 3 lc rgb 'blue' t "{/Times:Italic=20 v_{2}}  ",\
   1/0 lw 3 lc rgb 'green' t "{/Times:Italic=20 v_{3}}  "
}

# Update for lim2 steps
do for [i = 1:lim2] {
 t = t + dt

 # Earth
 xe = xe + ve*dt

 # Satellite 1
 vold = sqrt(y1**2+w1**2)              # Old
 x1 = x1 + rk4x(x1-xe, y1, z1, w1)
 y1 = y1 + rk4y(x1-xe, y1, z1, w1)
 z1 = z1 + rk4z(x1-xe, y1, z1, w1)
 w1 = w1 + rk4w(x1-xe, y1, z1, w1)
 vnew    = sqrt(y1**2+w1**2)           # New
 set arrow 3*(i-1)+2 nohead from t, vold to t, vnew lc rgb 'red' lw 2

 # Satellite 2
 vold = sqrt(y2**2+w2**2)              # Old
 x2 = x2 + rk4x(x2-xe, y2, z2, w2)
 y2 = y2 + rk4y(x2-xe, y2, z2, w2)
 z2 = z2 + rk4z(x2-xe, y2, z2, w2)
 w2 = w2 + rk4w(x2-xe, y2, z2, w2)
 vnew = sqrt(y2**2+w2**2)              # New
 set arrow 3*(i-1)+3 nohead from t, vold to t, vnew lc rgb 'blue' lw 2

 # Satellite 3
 vold = sqrt(y3**2+w3**2)              # Old
 x3 = x3 + rk4x(x3-xe, y3, z3, w3)
 y3 = y3 + rk4y(x3-xe, y3, z3, w3)
 z3 = z3 + rk4z(x3-xe, y3, z3, w3)
 w3 = w3 + rk4w(x3-xe, y3, z3, w3)
 vnew = sqrt(y3**2+w3**2)              # New
 set arrow 3*(i-1)+4 nohead from t, vold to t, vnew lc rgb 'green' lw 2

 # Decimate and plot
 if(i%cut==0){
  plot 1/0 lw 3 lc rgb 'red'   t "{/Times:Italic=20 v_{1}}  ",\
    1/0 lw 3 lc rgb 'blue'  t "{/Times:Italic=20 v_{2}}  ",\
    1/0 lw 3 lc rgb 'green' t "{/Times:Italic=20 v_{3}}  "
 }
}

set out