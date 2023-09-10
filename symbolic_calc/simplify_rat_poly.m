function [ num_n,den_n ] = simplify_rat_poly( num,den )
%SIMPLIFY_RAT_POLY Summary of this function goes here
%   Detailed explanation goes here

num_roots = roots(num);
den_roots = roots(den);

Kn = mean(num./poly(num_roots));
Kd = mean(den./poly(den_roots));

num_order = length(num_roots);

num_root_cancel_idx = [];

for i = 1:1:num_order
    roots_diff = abs(num_roots(i)-den_roots);
    first_idx = find(roots_diff<=(1e-5*abs(num_roots(i))),1);
    
    if(~isempty(first_idx))
        num_root_cancel_idx = [num_root_cancel_idx i];
        den_roots = [den_roots(1:first_idx-1);den_roots(first_idx+1:end)];
    end
end

num_roots(num_root_cancel_idx) = [];

num_n = (Kn/Kd)*poly(num_roots);
den_n = poly(den_roots);

end

