clc;
clear;

load('sys3.mat','A','B','C','n','m');

poles = linspace(-1,-0.1,2*n);
H = place(A',C',poles)';
eig(A-H*C)

% Q = 1000*eye(2*n);
% R = 1e-4*eye(m);
% 
% H = lqr(A',C',Q,R)';
    
if(exist('Gf_raw.mat','file')==2)
    load('Gf_raw.mat');
else
    [Gf,Gf_inc] = calculate_Gf(A,B,C,H); 
end

[W,WN_roots,WD_roots,WKm] = construct_W3(Gf);
[ M,M_inc ] = calculate_M( W,Gf );
[ Aw,Bw,Cw,Dw] = tfm2ss_v2( WN_roots,WD_roots,WKm );

%M = 0;
%M_inc = 0;

save('W_filt.mat','W','M','M_inc','Aw','Bw','Cw','Dw','Gf','Gf_inc','H');
