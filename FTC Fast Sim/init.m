clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%
% System Parameter %
%%%%%%%%%%%%%%%%%%%%%%%
global n m q A B C E F Fn Cn
global tfu tfy Fu_cell Fy_cell
global Kp Kd Ki GAMMA eps a b test_time_1 test_time_2 rho a_fd S_ref_nom
global tf tf2

load sys3.mat;

x0 = zeros(2*n,1);
%x0 = rand(2*n,1)-0.5;
%x0(2) = 3;

%xi0 = V*x0(1:n);
a = 0.001;      % Lower hysterisis limit for PID_PD control
b = 0.005;       % Upper hysterisis limit for PID_PD control
test_time_1 = 4e4;
test_time_2 = 3e4;
rho = 0.1;
a_fd = 5e-6;

%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs%
%%%%%%%%%%%%%%%%%%%%%%%
% Control
yref_idx = 1;
u_idx = yref_idx;

%yref = zeros(m,1);
%yref(yref_idx) = 10*(rand(2,1)-0.5);
%yref(yref_idx) = 0.01;

yref = [1; 2; 0.5; -2; -3];

% Set 1 - Many oscillation
%Kp_gain = 1.5e3;
%Kd_gain = 2.67e4;
%Ki_gain = 0.8;

% Set 2 - Satisfying Result
%Kp_gain = 3000;
%Kd_gain = 80000;
%Ki_gain = 0.0556;

% Set 3 - Fast Control
%Kp_gain = 30000;
%Kd_gain = 800000;
%Ki_gain = 1;

% Kp = Kp_gain*diag(ones(m,1));
% Kd = Kd_gain*diag(ones(m,1));
% Ki = Ki_gain*diag(ones(m,1));

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
S_ref_nom = (GAMMA + Kp)\Kp

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

tfu = [tf,-1,-1];
%tfu = [-1,-1,-1];
Fu = ones(m,1);
%Fu(u_idx(1)) = 0;
Fu(5) = 0;
Fu_cell= {Fu};

% Fu(u_idx(2)) = 0;
% Fu_cell= {Fu_cell{:},Fu};
% 
% Fu(u_idx(3)) = 0;
% Fu_cell= {Fu_cell{:},Fu};

% Sensor Fault
tfy = [tf2 -1];
%tfy = [tf -1];
Fy = ones(m,1);
%Fy(u_idx(1)) = 0;
Fy(3) = 0;
Fy_cell = {Fy};

