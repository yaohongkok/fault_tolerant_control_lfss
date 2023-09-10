clc;
clear;

load sys3.mat;

Kp_gain_arr = linspace(0,50,20);
%Kd_gain_arr = linspace(2.2e4,2.6e4,10);
Kd_gain_arr = 25000;
Ki_gain_arr = linspace(0,0.1,20);

stable_Kp = zeros(1000,1);
stable_Kd = zeros(1000,1);
stable_Ki = zeros(1000,1);
unstable_Kp = zeros(1000,1);
unstable_Kd = zeros(1000,1);
unstable_Ki = zeros(1000,1);

stable_counter = 1;
unstable_counter = 1;

I = eye(m);

Omega2 = -A(n+1:2*n,1:n);
Delta = -A(n+1:2*n,n+1:2*n);
L = B(n+1:2*n,:);

Cn = [L' zeros(m,n);zeros(m,n) L'];
Fn = [F;zeros(size(F))];
eps = 1;

best_slowest_pole = 0;

for ip = 1:1:length(Kp_gain_arr)
    
    Kp_gain = Kp_gain_arr(ip);
    Kp = Kp_gain*I;
    
    for id = 1:1:length(Kd_gain_arr)
        
        Kd_gain = Kd_gain_arr(id);
        Kd = Kd_gain*I;
        
        for ii = 1:1:length(Ki_gain_arr)
                
            Ki_gain = Ki_gain_arr(ii);
            Ki = Ki_gain*I;
            
            A_cls = [ zeros(n), eye(n), zeros(n,m)
                -Omega2 - L*Kp*L', -Delta - L*Kd*L', - eps*L*Ki
                L', zeros(m,n), zeros(m)];
            
            eig_A_cls = eig(A_cls);
            is_system_unstable = any(real(eig_A_cls)>=0);
            
            if(is_system_unstable)
                unstable_Kp(unstable_counter) = Kp_gain;
                unstable_Kd(unstable_counter) = Kd_gain;
                unstable_Ki(unstable_counter) = Ki_gain;
                
                unstable_counter = unstable_counter + 1;
            else
                stable_Kp(stable_counter) = Kp_gain;
                stable_Kd(stable_counter) = Kd_gain;
                stable_Ki(stable_counter) = Ki_gain;
                
                stable_counter = stable_counter + 1;
                
                slowest_pole = min(-real(eig_A_cls));
                if(slowest_pole>best_slowest_pole)
                    best_slowest_pole = slowest_pole;
                    best_Kp = Kp_gain;
                    best_Kd = Kd_gain;
                    best_Ki = Ki_gain;
                end
            end
        end
    end
end

unstable_Kp(unstable_counter:end) = [];
unstable_Kd(unstable_counter:end) = [];
unstable_Ki(unstable_counter:end) = [];
stable_Kp(stable_counter:end) = [];
stable_Kd(stable_counter:end) = [];
stable_Ki(stable_counter:end) = [];

best_slowest_pole,best_Kp,best_Kd,best_Ki

% plot3(unstable_Kp,unstable_Kd,unstable_Ki,'.r');
% hold on
% plot3(stable_Kp,stable_Kd,stable_Ki,'ob');
% hold off
% xlabel('Kp');
% ylabel('Kd');
% zlabel('Ki');