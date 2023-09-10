function [ p ] = construct_poly_roots( roots )
%CONSTRUCT_POLY Summary of this function goes here
%   Detailed explanation goes here

p = sym(1);
s = sym('s');

if(~isempty(roots))
    for i = 1:1:length(roots)
        p = p*(s-roots(i));
    end
    p = expand(p);
end

end

