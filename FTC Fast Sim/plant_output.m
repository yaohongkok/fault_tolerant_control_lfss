function [ y_t ] = plant_output( inp )
%PLANT_MODEL Summary of this function goes here
%   Detailed explanation goes here

global n m q Cn Fn

x = inp(1:2*n);
Fy_element = inp(2*n+1:2*n+m);
w = inp(2*n+m+1:2*n+m+q);

Fy = diag(Fy_element,0);
Fy = blkdiag(Fy,Fy);
Y_act = (Cn*x+Fn*w);        % y and y_dot

y_t = [Fy*Y_act;Y_act(1:m)];


end

