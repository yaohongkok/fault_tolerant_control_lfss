function Sam_FD(block)
% Level-2 M file S-Function for unit delay demo.
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

setup(block);
end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setup(block)

block.NumDialogPrms  = 0;

% Register number of input and output ports
block.NumInputPorts  = 3;
block.NumOutputPorts = 3;


% Setup functional port properties to dynamically
% inherited.
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).DimensionsMode = 'Fixed';
block.InputPort(1).Dimensions        = -1;        % Y_mat
block.InputPort(1).DirectFeedthrough = true;

block.InputPort(2).DimensionsMode = 'Fixed';
block.InputPort(2).Dimensions        = -1;        % y_ref
block.InputPort(2).DirectFeedthrough = true;

block.InputPort(3).DimensionsMode = 'Fixed';
block.InputPort(3).Dimensions        = 1;        % fault detection flag
block.InputPort(3).DirectFeedthrough = true;

block.OutputPort(1).DimensionsMode = 'Fixed';
block.OutputPort(1).Dimensions        = -1;     % y_ref + del_y_ref
block.OutputPort(1).SamplingMode = 0;

block.OutputPort(2).DimensionsMode = 'Fixed';
block.OutputPort(2).Dimensions        = -1;      % F (vectorized) 
block.OutputPort(2).SamplingMode = 0;

block.OutputPort(3).Dimensions        = 1;      % fd_flag 
block.OutputPort(3).SamplingMode = 0;

% Set block sample time to inherited
block.SampleTimes = [-1 0];

% Set the block simStateComliance to default (i.e., same as a built-in block)
block.SimStateCompliance = 'DefaultSimState';

% Register methods
block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions',    @InitConditions);
block.RegBlockMethod('Outputs',                 @Output);
block.RegBlockMethod('SetInputPortDimensions',  @SetInpPortDimensions);
block.RegBlockMethod('SetInputPortSamplingMode',@SetInputPortSamplingMode);
%block.RegBlockMethod('Update',                  @Update);
end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetInpPortDimensions(block, port, dimsInfo)

block.InputPort(port).Dimensions = dimsInfo;

if(port == 2)
    block.OutputPort(1).Dimensions = dimsInfo;
    block.OutputPort(2).Dimensions = dimsInfo;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetInputPortSamplingMode(block, port, mode)

block.InputPort(port).SamplingMode = mode;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoPostPropSetup(block)

%Setup Dwork
block.NumDworks = 6;
block.Dwork(1).Name = 'step_counter';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0;
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = false;

block.Dwork(2).Name = 'fd_flag';
block.Dwork(2).Dimensions      = 1;
block.Dwork(2).DatatypeID      = 0;
block.Dwork(2).Complexity      = 'Real';
block.Dwork(2).UsedAsDiscState = false;

block.Dwork(3).Name = 'F_vector';
block.Dwork(3).Dimensions      = block.OutputPort(2).Dimensions;
block.Dwork(3).DatatypeID      = 0;
block.Dwork(3).Complexity      = 'Real';
block.Dwork(3).UsedAsDiscState = false;

block.Dwork(4).Name = 'Z';
block.Dwork(4).Dimensions      = (block.OutputPort(2).Dimensions)^2;
block.Dwork(4).DatatypeID      = 0;
block.Dwork(4).Complexity      = 'Real';
block.Dwork(4).UsedAsDiscState = false;

block.Dwork(5).Name = 'count_inc_time';
block.Dwork(5).Dimensions      = 1;
block.Dwork(5).DatatypeID      = 0;
block.Dwork(5).Complexity      = 'Real';
block.Dwork(5).UsedAsDiscState = false;

block.Dwork(6).Name = 'y_ss';
block.Dwork(6).Dimensions      = block.OutputPort(2).Dimensions;
block.Dwork(6).DatatypeID      = 0;
block.Dwork(6).Complexity      = 'Real';
block.Dwork(6).UsedAsDiscState = false;

end
% endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitConditions(block)

m = block.OutputPort(2).Dimensions;

% Step Counter (which S/A are we testing)
block.Dwork(1).Data = 0;

% Fault Diagnosis Flag (No == 0, Yes == 1)
block.Dwork(2).Data = 0;

% F_vector
block.Dwork(3).Data = ones(m,1);

% Z
block.Dwork(4).Data = zeros(m^2,1);

%count_time (-1 means no fault count previously)
block.Dwork(5).Data = -1;

% Steady State y from pure PD control
block.Dwork(6).Data = zeros(m,1);

end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Output(block)

global S_ref_nom test_time_1 test_time_2 rho a_fd

m = block.InputPort(2).Dimensions ;
fault_detected = block.InputPort(3).Data;
Y_mat = block.InputPort(1).Data;
y = Y_mat(1:m);
y_dot = Y_mat(m+1:2*m);
y_ref = block.InputPort(2).Data;

i = block.Dwork(1).Data; % Step Counter
fd_flag = block.Dwork(2).Data;
F_vector = block.Dwork(3).Data;
Z = vec2mat(block.Dwork(4).Data, m);
count_time = block.Dwork(5).Data;
y_ss = block.Dwork(6).Data;

isMajorTimeStep = block.IsMajorTimeStep();

% First Detect Fault
if(fault_detected == 1 && isMajorTimeStep)
    fd_flag = 1;
    block.Dwork(2).Data = fd_flag;
end
% if(fault_detected == 0 && isMajorTimeStep)
%     fd_flag = 0;
%     block.Dwork(2).Data = fd_flag;
% end

% Determine if we want to do fault diagnosis
if(fd_flag == 0)
    % Don't change reference input if no falt
    block.OutputPort(1).Data = diag(F_vector)*y_ref;
end
if(fd_flag == 1)
    time = block.currentTime;
    % The first step of FD: Determine Steady State of y with just y_ref
    if(i==0)
        y_ref_n = y_ref;
        
        % When PD control just started
        if(count_time == -1)
            if(isMajorTimeStep)
                block.Dwork(5).Data = time;     % Overwrite count time
            end
        end
        
        % When PD control with y_ref reached steady state
        if(norm(y_dot,2)<a_fd*norm(y_ref,2) && count_time~=-1 && time>count_time+test_time_1)
            if(isMajorTimeStep)
                y_ss = y;
                block.Dwork(6).Data = y_ss;
                i = i + 1;
                block.Dwork(1).Data = i;
                del_y = zeros(m,1);
                del_y(i) = 1;
                y_ref_n = y_ref + rho*del_y;
                
                block.Dwork(5).Data = time;     % Overwrite count time
            end
        end
        
        block.OutputPort(1).Data = y_ref_n;
    else
        if(i>0)
            % Not yet steady state
            del_y = zeros(m,1);
            del_y(i) = 1;
            y_ref_n = y_ref + rho*del_y;
            
%             if(isMajorTimeStep)
%                 norm(y_dot,2)
%             end
            
            % When PD control with y_ref+del_y reached steady state
            if(norm(y_dot,2)<a_fd*norm(y_ref,2) && time>count_time+test_time_2)
                % The last actuator/sensor response has reached steady state
                if(i == m)
                    if(isMajorTimeStep)
                        y_i_ss = y;
                        Z(:,i) = (1/rho)*(y_i_ss - y_ss);
                        
                        for j = 1:1:m
                            if(abs(Z(j,j)) <S_ref_nom(j,j))
                                F_vector(j) = 0;
                            else
                                F_vector(j) = 1;
                            end
                        end
                        
                        block.Dwork(3).Data = F_vector;
                        y_ref_n = y_ref;
                        
                        % FD flag reset
                        fd_flag = 0;
                        block.Dwork(2).Data = fd_flag;
                        
                        %Counter reset
                        i = 0;
                        block.Dwork(1).Data = i;
                        
                        % Z reset
                        block.Dwork(4).Data = zeros(m^2,1);
                        
                        % Count Time Reset
                        block.Dwork(5).Data = -1;
                        
                        % Steady State y reset
                        block.Dwork(6).Data = zeros(m,1);
                    end
                else
                    % i~=m && it is steady state
                    if(isMajorTimeStep)
                        y_i_ss = y;
                        Z(:,i) = (1/rho)*(y_i_ss - y_ss);
                        block.Dwork(4).Data = Z(:);
                        i = i + 1;
                        block.Dwork(1).Data = i;
                        del_y = zeros(m,1);
                        del_y(i) = 1;
                        y_ref_n = y_ref + rho*del_y;
                        
                        block.Dwork(5).Data = time;     % Overwrite count time
                    end
                end
            end
            
            block.OutputPort(1).Data = y_ref_n;
        end
    end
    
end


block.OutputPort(2).Data = F_vector;
block.OutputPort(3).Data = fd_flag;
end
%endfunction


