function [ M,M_inc ] = calculate_M( W,Gf )
%COMPUTE_M Summary of this function goes here
%   Detailed explanation goes here


M = W*Gf;
fprintf('Processing M(s)...\n');
[Nm,Dm] = numden(M);
[Nm,Dm] = simplify_rat_poly_matrix( Nm,Dm);
M_float = struct('num',cell(m,2*m),'den',cell(m,2*m));

M_inc = zeros(m,2*m);

for i = 1:1:m
    for j = 1:1:2*m
        M_float(i,j).num = sym2poly(Nm(i,j));
        M_float(i,j).den = sym2poly(Dm(i,j));
        M_inc(i,j) = log10(max(abs(M_float(i,j).num))/max(abs(M_float(i,j).den)))
    end
end

M_inc

end

