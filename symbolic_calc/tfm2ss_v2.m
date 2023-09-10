function [ Aw,Bw,Cw,Dw] = tfm2ss_v2( WN_roots, WD_roots,WKm)
%TFM2SS Summary of this function goes here
%   Detailed explanation goes here


sys = zpk(WN_roots,WD_roots,WKm);

% Construct the system
W_filter = ss(sys,'minimal');
Aw = W_filter.a;
Bw = W_filter.b;
Cw = W_filter.c;
Dw = W_filter.d;

end

