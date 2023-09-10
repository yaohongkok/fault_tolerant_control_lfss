clc;
clear;

global n m q A B E C F Cn Fn
global tfu tfy Fu_cell Fy_cell
global test_time_1 a_fd b_fd

load('sys3.mat');
[n,m] = size(B);
[n,q]= size(E);
n = n/2;
%x0 = zeros(2*n,1);
x0 = randn(2*n,1);
L = B(n+1:2*n,:);
Cn = [L' zeros(m,n);zeros(m,n) L'];
Fn = [F;zeros(size(F))];

%%%%%%%%%%%%%%%%%%%%%%%%
% Fault Isolator %
%%%%%%%%%%%%%%%%%%%%%%%%
load('W_filt.mat');
Cw = 1e4*Cw;
Dw = 1e4*Dw;

test_time_1 = 1.5;
a_fd = 5e-7;
b_fd = 1e-2;

%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs%
%%%%%%%%%%%%%%%%%%%%%%%
% Control
u_idx = 4;

u = zeros(m,1);
u(u_idx) = 3;

w = zeros(q,1);

% Actuator Fault
%tfu = -1;
tfu = [200,-1,-1];
Fu = ones(m,1);
Fu(u_idx(1)) = 0;
Fu_cell= {Fu};

% Fu(u_idx(2)) = 0;
% Fu_cell= {Fu_cell{:},Fu};
% 
% Fu(u_idx(3)) = 0;
% Fu_cell= {Fu_cell{:},Fu};

% Sensor Fault
tfy = [-1 -1];
Fy = ones(m,1);
%Fy(u_idx(1)) = 0;
Fy(5) = 0;
Fy_cell = {Fy};

     