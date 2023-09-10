function [ Fy_out ] = sensor_fault( t )
%ACTUATOR_FAULT Summary of this function goes here
%   Detailed explanation goes here
global tfy Fy_cell m

p =m;

Fy_out = ones(p,1);

% if(tfy>0)
%    if(t>=tfy)
%        Fy_out = Fy;
%    end
% end

lt =length(tfy);
count = 1;

if(tfy(1)>0 && t>=tfy(1))
    for i = 2:1:lt
        if(t>=tfy(i) && tfy(i)>=0)
            count = count + 1;
        end
    end
    
    Fy_out = Fy_cell{count};
end


end

