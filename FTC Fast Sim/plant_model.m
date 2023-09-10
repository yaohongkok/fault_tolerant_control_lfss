function [ x_dot ] = plant_model( inp )
%PLANT_MODEL Summary of this function goes here
%   Detailed explanation goes here

global n m q A B E

x = inp(1:2*n);
u = inp(2*n+1:2*n+m);
w = inp(2*n+m+1:2*n+m+q);
Fu_element = inp(2*n+m+q+1:2*n+m+q+m);
t = inp(2*n+m+q+m+1);

Fu = diag(Fu_element,0);
%fprintf('\n %%%%%%%%%%%%%%%\n');
%t
x_dot = A*x + B*Fu*u + E*w;

end

