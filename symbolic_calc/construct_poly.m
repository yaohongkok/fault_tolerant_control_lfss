function [ p ] = construct_poly( c )
%CONSTRUCT_POLY Summary of this function goes here
%   Detailed explanation goes here

p = 0;
ord = 1;
s = sym('s');

for i = 1:1:length(c)
   p = p +  ord*c(i);
   ord = ord*s;
end

end

