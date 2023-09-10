function myFD(block)
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
block.NumInputPorts  = 2;
block.NumOutputPorts = 2;


% Setup functional port properties to dynamically
% inherited.
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).DimensionsMode = 'Fixed';
block.InputPort(1).Dimensions        = -1;        % r'
block.InputPort(1).DirectFeedthrough = true;

block.InputPort(2).DimensionsMode = 'Fixed';
block.InputPort(2).Dimensions        = -1;        % r
block.InputPort(2).DirectFeedthrough = true;

block.OutputPort(1).DimensionsMode = 'Fixed';
block.OutputPort(1).Dimensions        = -1;      % F (vectorized) 
block.OutputPort(1).SamplingMode = 0;

block.OutputPort(2).DimensionsMode = 'Fixed';
block.OutputPort(2).Dimensions        = 1;      % fd_flag 
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

block.OutputPort(1).Dimensions = dimsInfo;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetInputPortSamplingMode(block, port, mode)

block.InputPort(port).SamplingMode = mode;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DoPostPropSetup(block)

%Setup Dwork
block.NumDworks = 5;

block.Dwork(1).Name = 'F_vector';
block.Dwork(1).Dimensions      = block.OutputPort(1).Dimensions;
block.Dwork(1).DatatypeID      = 0;
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = false;

block.Dwork(2).Name = 'fd_flag';
block.Dwork(2).Dimensions      = 1;
block.Dwork(2).DatatypeID      = 0;
block.Dwork(2).Complexity      = 'Real';
block.Dwork(2).UsedAsDiscState = false;

block.Dwork(3).Name = 'fault_time';
block.Dwork(3).Dimensions      = 1;
block.Dwork(3).DatatypeID      = 0;
block.Dwork(3).Complexity      = 'Real';
block.Dwork(3).UsedAsDiscState = false;

block.Dwork(4).Name = 'r_max';
block.Dwork(4).Dimensions      = block.OutputPort(1).Dimensions;
block.Dwork(4).DatatypeID      = 0;
block.Dwork(4).Complexity      = 'Real';
block.Dwork(4).UsedAsDiscState = false;

block.Dwork(5).Name = 'fd_done';
block.Dwork(5).Dimensions      = 1;
block.Dwork(5).DatatypeID      = 0;
block.Dwork(5).Complexity      = 'Real';
block.Dwork(5).UsedAsDiscState = false;

end
% endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function InitConditions(block)

m = block.OutputPort(1).Dimensions;
% F_vector
block.Dwork(1).Data = ones(m,1);
% fd_flag (0 == not in fault detection mode)
block.Dwork(2).Data = 0;
% fault time
block.Dwork(3).Data = -1;
% max res val over time
block.Dwork(4).Data = zeros(m,1);
% Just finished fault diagnosis
block.Dwork(5).Data = 0;

end
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Output(block)

global test_time_1 a_fd b_fd transient_wait

isMajorTimeStep = block.IsMajorTimeStep();

if(isMajorTimeStep)
    F_vector = block.Dwork(1).Data;
    fd_flag = block.Dwork(2).Data;
    time =  block.currentTime;
    
    if(time >= transient_wait)
        fault_time = block.Dwork(3).Data;
        r_max = block.Dwork(4).Data ;
        rp = block.InputPort(1).Data;
        r = block.InputPort(2).Data;
        fd_fin = block.Dwork(5).Data;
        
        % Fault occurred. Start Fault diagnosis
        if(norm(r,2)>=a_fd &&  fd_flag == 0 && fd_fin == 0)
            fd_flag = 1;
            fault_time = time;
            
            block.Dwork(2).Data = fd_flag;
            block.Dwork(3).Data = fault_time;
        else
            
            % Gather information on structured residuals
            if(fd_flag == 1 && time<fault_time+ test_time_1&& fd_fin==0)
                r_con = [r_max abs(rp)];
                r_max = max(r_con,[],2);
                
                block.Dwork(4).Data = r_max;
            end
            
            if(fd_flag == 1 && time>=fault_time+ test_time_1 && fd_fin == 0)
                [r_max_small,idx] = min(r_max);
                r_max_med = median(r_max);
                
                if(abs(r_max_small - r_max_med)<b_fd)
                    F_vector(idx) = 0;
                end
                
                fd_flag = 0;
                fault_time = -1;
                fd_fin = 1;
                
                block.Dwork(2).Data = fd_flag;
                block.Dwork(3).Data = fault_time;
                block.Dwork(1).Data = F_vector;
                block.Dwork(4).Data = 0*r_max;
                block.Dwork(5).Data = fd_fin;
            end
            
            % Revert back to no fault diagnosis
            if(norm(r,2)<0.1*a_fd && fd_fin == 1)
                fd_fin = 0;
                block.Dwork(5).Data = fd_fin;
            end
            
        end
        
    else
        F_vector = [1 1 1 1 1];
        fd_flag = 0;
    end
end

block.OutputPort(1).Data = F_vector;
block.OutputPort(2).Data = fd_flag;
end
%endfunction


