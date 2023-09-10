function [ Q ] = gen_orth_matrix( n,K )
%GEN_ORTH_MATRIX Summary of this function goes here
%   Detailed explanation goes here

Q = orth( K*2*(rand(n)-0.5));
% Q = orth( (randi([1,K],n,n)));
% Q = floor(Q*1000)/1000;

end

