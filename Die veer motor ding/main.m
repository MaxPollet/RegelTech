clc
clear

%% Parameters init
K_stiff = 1.60856;  % Spring stiffness
K_g     = 70;       % Motor gear ratio
K_m     = 0.00767;  % Motor torque constant
K_b     = 0.00767;  % Motor back EMF constant
J_h     = 0.0021;   % Hub inertia
R_m     = 2.6;      % Motor armature resistance
J_l     = 0.0059;   % Arm inertia
d       = 0.0318;   % Body anchor point (y)
R       = 0.076;    % Arm anchor point
r       = 0.0318;   % Body anchor point (x)
F_r     = 1.33;     % Spring restoring force
L       = 0.0318;   % Spring length at rest

%% State space description
A = [0,  0,                             1,                           0; 
     0,  0,                             0,                           1; 
     0,  K_stiff/J_h,                  -((K_g)^2*K_m*K_b)/(J_h*R_m), 0;
     0, -((J_h+J_l)*K_stiff)/(J_h*J_l), ((K_g)^2*K_m*K_b)/(J_h*R_m), 0];

B = [ 0; 
      0; 
      (K_m*K_g)/(R_m*J_h);
     -(K_m*K_g)/(R_m*J_h)];

C = [1 0 0 0;
     0 1 0 0];
D = zeros(2,1);

System = ss(A, B, C, D);
fprintf("The eigenvalues of the matrix A:")
eig(A)
fprintf("The poles of the system are:")
pole(System)
fprintf("The system is minimal\n")
Z = tzero(A, B, C, D);
fprintf("The system has no transmission zeros")
fprintf("The rank of the controllability matrix is: %d\n", rank(ctrb(A,B)));
fprintf("The rank of the observability matrix is: %d\n", rank(obsv(A,C)));
%% Controller
C_c = eye(4);
D_c = zeros(4,1);

Q = {[350, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 0.5];
       [10, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 0.5];
       [350, 0,    0, 0; 
       0,   1000, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 0.5];
       [350, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    50, 0;
       0,   0,    0, 0.5];
       [350, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 5];
       [350, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 0.5];
       [350, 0,    0, 0; 
       0,   1500, 0, 0; 
       0,   0,    3, 0;
       0,   0,    0, 0.5]};

R = {10 10 10 10 10 0.1 100};

for i=1:length(Q)
    Q_c = Q(i);
    R_c = R(i);
    
    [K, S, P] = lqr(System, Q_c, R_c);
    
    sim = 
end
% Q_c = [350, 0,    0, 0; 
%        0,   1500, 0, 0; 
%        0,   0,    3, 0;
%        0,   0,    0, 0.5];
% 
% R_c = 10;

% [K,S,P] = lqr(System,Q_c,R_c);

fprintf("The closed-loop eigenvalues are:")
display(P)
