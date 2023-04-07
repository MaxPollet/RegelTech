%% Syms initialization

% states
syms x y z vx vy vz phi theta psi wx wy wz ;

% inputs
syms v21 v22 v23 v24

% parameters
syms m L k b g kd Ixx Iyy Izz cm;


%% for values

% m = 0.5;
% L = 0.25;
% k = 3*10^(-6);
% b = 10^(-7);
% g = 9.81;
% kd = 0.25;
% Ixx = 5*10^(-3);
% Iyy = 5*10^(-3);
% Izz = 10^(-2);
% cm = 10^(4);



%% Equilibrium point at y* = 0
psi_0 = 0;
phi_0 = 0;
theta_0 = 0;
x_0 = 0;
y_0 = 0;
z_0 = 0;

f1 = vx;
f2 = vy;
f3 = vz;
f4_a = -(kd/m)*vx; 
f4_b = (k*cm/m)*(sin(psi)*sin(phi)+cos(phi)*cos(psi)*sin(theta))*(v21+v22+v23+v24);

f4 = f4_a + f4_b;

f5_a = -(kd/m)*vy;
f5_b = (k*cm/m)*(cos(phi)*sin(psi)*sin(theta)-cos(psi)*sin(phi))*(v21+v22+v23+v24);

f5 = f5_a + f5_b;

f6_a = -(kd/m)*vz - g;
f6_b = (k*cm/m)*(cos(theta)*cos(phi))*(v21+v22+v23+v24);

f6 = f6_a + f6_b;

f7 = wx + wy*(sin(phi)*tan(theta)) + wz*(cos(phi)*tan(theta));
f8 = wy*cos(phi) - wz*sin(phi);
f9 = sin(phi)/cos(theta)*wy + cos(phi)/cos(theta)*wz;
f10_a =  -((Iyy- Izz)/Ixx)*wy*wz;
f10_b = (L*k*cm/Ixx)*(v21- v23);

f10 = f10_a + f10_b;

f11_a = -((Izz- Ixx)/Iyy)*wx*wz;
f11_b = (L*k*cm/Iyy)*(v22- v24);

f11 = f11_a + f11_b;

f12_a =  -((Ixx - Iyy)/Izz)*wx*wy;
f12_b = (b*cm/Izz)*(v21- v22+ v23 - v24);

f12 = f12_a + f12_b;




%% jacobiaan om de a matrix te maken
J_a = jacobian([f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12],[ x y z vx vy vz phi theta psi wx wy wz]);

%% jacobiaan om de B matrix te maken
J_b = jacobian([f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12],[v21 v22 v23 v24]);

%% De equilibrium waardes in de Jacobiaan steken
%maar omdat er geen wx wy wz equib waardes zijn is het nog steeds
%nonlineair???
Js_a = subs(J_a, [x y z theta psi phi, wx, wy, wz, v21, v22, v23, v24], [0 0 0 0 0 0 0 0 0 40.875 40.875 40.875 40.875]); 
%A = double(Js_a);
Js_b = subs(J_b, [x y z theta psi phi, wx, wy, wz], [0 0 0 0 0 0 0 0 0]);
%B = double(Js_b);






A = double(subs(Js_a, [m L k b g kd Ixx Iyy Izz cm ], [0.5 0.25 3*10^(-6) 10^(-7) 9.81 0.25 5*10^(-3) 5*10^(-3) 10^(-2) 10^(4) ])); 
B = double(subs(Js_b, [m L k b g kd Ixx Iyy Izz cm], [0.5 0.25 3*10^(-6) 10^(-7) 9.81 0.25 5*10^(-3) 5*10^(-3) 10^(-2) 10^(4)])); 
C1 = [eye(3), zeros(3), zeros(3), zeros(3); zeros(3), zeros(3), eye(3), zeros(3)];
C = eye(12);
D = zeros(12,4);



System = ss(A,B,C,D);

%%%%%%%%%%%%%%%%%%%%%%%%
%DIscriti
%%%%%%%%%%%%%%%%%%%%%%%%
Ts = 0.05;
Zero_hold = c2d(System,Ts);
pole(Zero_hold)
rank(ctrb(Zero_hold))
rank(obsv(Zero_hold))


Tustin = c2d(System,Ts, 'tustin');
pole(Tustin)
rank(ctrb(Tustin))
rank(obsv(Tustin))

euler = c2d(System,Ts, 'forward');
pole(euler)
rank(ctrb(euler))
rank(obsv(euler))


[a,b,c,d] = ssdata(Tustin); 

%%%%%%%%%%%%%%%%%%%%%%%%
%control
%%%%%%%%%%%%%%%%%%%%%%%%

Q = eye(12);
Q(1,1) = 10;
Q(2,2) = 10;
Q(3,3) = 1000000;
R = eye(4);

[K,S,P] = lqr(Tustin,Q,R);