clc;
clear;

load('temp');

num_order = zeros(5);
den_order = zeros(5);

for i= 1:1:5
    for j = 1:1:5
        [N,D] = numden(W(i,j));
        num_order(i,j) = length(sym2poly(N));
        den_order(i,j) = length(sym2poly(D));
    end
end
        