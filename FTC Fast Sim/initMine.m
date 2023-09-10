clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%
% System Parameter %
%%%%%%%%%%%%%%%%%%%%%%%
global n m q A B C E F Fn Cn
global tfu tfy Fu_cell Fy_cell
global Kp Kd Ki GAMMA eps a b
global test_time_1 a_fd b_fd transient_wait
global tf tf2

%%%%%%%%%%%%%%%%%%%%%%%%
% System Related
%%%%%%%%%%%%%%%%%%%%%%%%
load sys3.mat;
[n,m] = size(B);
[n,q]= size(E);
n = n/2;
x0 = zeros(2*n,1);
L = B(n+1:2*n,:);
Cn = [L' zeros(m,n);zeros(m,n) L'];
Fn = [F;zeros(size(F))];

%%%%%%%%%%%%%%%%%%%%
% PD Control Related
%%%%%%%%%%%%%%%%%%%%
a = 0.001;      % Lower hysterisis limit for PID_PD control
b = 0.005;       % Upper hysterisis limit for PID_PD control

%%%%%%%%%%%%%%%%%%%%
% FD Related
%%%%%%%%%%%%%%%%%%%%
test_time_1 = 1.5;
a_fd = 5e-5;
b_fd = 1e-2;
transient_wait = 50;

load('W_filt.mat');
Cw = 1e4*Cw;
Dw = 1e4*Dw;

%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs%
%%%%%%%%%%%%%%%%%%%%%%%
% Control
yref = [1; 2; 0.5; -2; -3];

% Set 4 - Sam Example
Kp_gain = 500;
Kd_gain = 4e4;
Ki_gain = 1;

DK = diag([1 1 4 1 1]);
Kp = Kp_gain*DK;
Kd = Kd_gain*DK;
Ki = Ki_gain*DK;

eps = 0.5;

Omega2 = -A(n+1:2*n,1:n);
Delta = -A(n+1:2*n,n+1:2*n);
L = B(n+1:2*n,:);

Cn = [L' zeros(m,n);zeros(m,n) L'];
Fn = [F;zeros(size(F))];

GAMMA = inv(L'/(Omega2+ L*L')*L) - eye(m);

A_cls = [ zeros(n), eye(n), zeros(n,m)
          -Omega2 - L*Kp*L', -Delta - L*Kd*L', - eps*L*Ki
          L', zeros(m,n), zeros(m)];

B_cls = [ -zeros(n,m); L*Kp; -eye(m)];

x_eta_steady_state = -inv(A_cls)*B_cls*yref;
y_steady_state = C*x_eta_steady_state(1:2*n)
      
eig_A_cls = eig(A_cls)
if (any(eig_A_cls>=0))
    fprintf('Close Loop System Not Stable. \n');
end

real_pole = -real(eig_A_cls);
slowest_pole = min(real_pole)
mean_pole = mean(real_pole)
std_pole = std(real_pole)

w = zeros(q,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Faults %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actuator Fault

tf = 3000;
tf2 = 4500;

tfu = [tf,tf2,-1];
%tfu = [-1,-1,-1];
Fu = ones(m,1);
Fu(5) = 0;
Fu_cell= {Fu};
Fu(1) = 0;
Fu_cell= {Fu_cell{1},Fu};


% Sensor Fault
tfy = [-1 -1];
%tfy = [tf tf2];
Fy = ones(m,1);
%Fy(u_idx(1)) = 0;
Fy(1) = 0;
Fy_cell = {Fy};

Fy(5) = 0;
Fy_cell = {Fy_cell{1};Fy};

