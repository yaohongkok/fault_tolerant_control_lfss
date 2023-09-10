function [ fd ] = fault_time( t )
%FAULT_TIME Summary of this function goes here
%   Detailed explanation goes here

global tf

fd = 0;

if(t>= tf && tf>0)
    if(t<tf+2)
        fd = 1;
    else
        fd = 0;
    end
end

end

