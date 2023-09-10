function PID_PD_4(block)
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
block.NumInputPorts  = 4;
block.NumOutputPorts = 2;


% Setup functional port properties to dynamically
% inherited.
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).DimensionsMode = 'Fixed';
block.InputPort(1).Dimensions        = -1;        % y - y_ref, y_dot, int(y-y_ref)
block.InputPort(1).DirectFeedthrough = true;

block.InputPort(2).DimensionsMode = 'Fixed';
block.InputPort(2).Dimensions        = -1;        % Matrix F
block.InputPort(2).DirectFeedthrough = true;

block.InputPort(3).DimensionsMode = 'Fixed';
block.InputPort(3).Dimensions        = -1;        % y_ref
block.InputPort(3).DirectFeedthrough = true;

block.InputPort(4).DimensionsMode = 'Fixed';
block.InputPort(4).Dimensions        = 1;         % Fault Diagnosis flag
block.InputPort(4).DirectFeedthrough = true;

block.OutputPort(1).DimensionsMode = 'Fixed';
block.OutputPort(1).Dimensions        = -1;     % u
block.OutputPort(1).SamplingMode = 0;

block.OutputPort(2).DimensionsMode = 'Fixed';
block.OutputPort(2).Dimensions        = 1;      % Integrator Reset
block.OutputPort(2).SamplingMode = 0;

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

if(port == 1)
    block.OutputPort(1).Dimensions = dimsInfo/3;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetInputPortSamplingMode(block, port, mode)

block.InputPort(port).SamplingMode = mode;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoPostPropSetup(block)

%Setup Dwork
block.NumDworks = 4;
block.Dwork(1).Name = 'gamma';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0;
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = false;

block.Dwork(2).Name = 'IR';
block.Dwork(2).Dimensions      = 1;
block.Dwork(2).DatatypeID      = 0;
block.Dwork(2).Complexity      = 'Real';
block.Dwork(2).UsedAsDiscState = false;

block.Dwork(3).Name = 'y_ref_prev';
block.Dwork(3).Dimensions      = block.OutputPort(1).Dimensions;
block.Dwork(3).DatatypeID      = 0;
block.Dwork(3).Complexity      = 'Real';
block.Dwork(3).UsedAsDiscState = false;

block.Dwork(4).Name = 'pd_time';
block.Dwork(4).Dimensions      = 1;
block.Dwork(4).DatatypeID      = 0;
block.Dwork(4).Complexity      = 'Real';
block.Dwork(4).UsedAsDiscState = false;


end
% endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitConditions(block)

% gamma (PID == 1, PD == 0)
block.Dwork(1).Data = 1;

% Integrator Reset
block.Dwork(2).Data = 0;

% Steady State Integrator Output
block.Dwork(3).Data = zeros(block.OutputPort(1).Dimensions,1);

% PD time
block.Dwork(4).Data = -1;

end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Output(block)
%block.CurrentTime
global Kp Kd Ki eps a b GAMMA

F = diag(block.InputPort(2).Data);
Y_mat = block.InputPort(1).Data;
y_ref = block.InputPort(3).Data;
fd_flag = round(block.InputPort(4).Data);  %fd_flag = 0 -> no fault diagnosis
                                    %fd_flag = 1 -> fault diagnosis

%block.CurrentTime
m = length(Y_mat)/3;
del_y = Y_mat(1:m);         %y - y_ref
y_dot = Y_mat(m+1:2*m);
eta = Y_mat(2*m+1:3*m);     %int(y-y_ref)

IR = block.Dwork(2).Data;
pd_time = block.Dwork(4).Data;

% if(~block.IsMajorTimeStep)
%     fprintf('Craps\n');
% end

if(fd_flag==0)
    gamma_prev = block.Dwork(1).Data;
    % Assume to use the same controller if nothing special happens
    gamma = gamma_prev;
    % Requires to use hysteris to determine whether to change gamma
    % Just in case y_dot and del_y oscilate about the limit
    y_ref_prev = block.Dwork(3).Data;
    
    % PD mode
    if ((norm(y_dot,2)<a*norm(y_ref,2)) && (norm(del_y,2)<b*norm(y_ref,2)))
        gamma = 0;
          
        if(block.IsMajorTimeStep)
            t = block.CurrentTime;
  
            if(IR==0 && gamma_prev == 1)
                pd_time = t;
                block.Dwork(4).Data = pd_time;
            end
            
            IR = 1;
        end
    end
    
    % When there is a chang in reference signal
    % Go to PID mode
    if (norm(y_ref-y_ref_prev,2)~=0)
        IR = 0;
        gamma = 1;
    end
    
    % Compute Control
    if(gamma == 1)
        u = F*(-Kp*F*del_y - Kd*F*y_dot - eps*Ki*F*eta);
    end
    if(gamma == 0)
        % Question: Do we need F for GAMMA? Probably not...
        u = F*(-Kp*F*del_y - Kd*F*y_dot - GAMMA*y_ref);
    end
end

if(fd_flag==1)
    gamma = 0;
    
%     block.currentTime,y_ref
    
    %PD mode
    if(block.IsMajorTimeStep)
        IR = 1;
    end
    
    u = F*(-Kp*F*del_y - Kd*F*y_dot);
end

if(block.IsMajorTimeStep)
    % gamma (PID == 1, PD == 0)
    block.Dwork(1).Data = gamma;
    % Integrator Reset
    block.Dwork(2).Data = IR;
    % y_ref_prev
    block.Dwork(3).Data = y_ref;
end

block.OutputPort(1).Data = u;
block.OutputPort(2).Data = IR;
end
%endfunction


