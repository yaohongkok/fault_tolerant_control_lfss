function [ Fu_out ] = actuator_fault( t )
%ACTUATOR_FAULT Summary of this function goes here
%   Detailed explanation goes here
global tfu Fu_cell m

Fu_out = ones(m,1);

lt =length(tfu);
count = 1;

if(tfu(1)>0 && t>=tfu(1))
    for i = 2:1:lt
        if(t>=tfu(i) && tfu(i)>=0)
            count = count + 1;
        end
    end
    
    Fu_out = Fu_cell{count};
end

end

