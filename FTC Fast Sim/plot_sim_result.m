close all
t = xs.time;
x = xs.signals.values;
y = ys.signals.values;
r = rs.signals.values;
r_isol = r_isol_s.signals.values;

figure('Name','State (modal position)')
for i = 1:1:n
    subplot(4,3,i)
    plot(t,x(:,i))
    state_num_text = sprintf('x_{%d}',i);
    ylabel(state_num_text);
    grid on
end

figure('Name','State (modal velocity)')
for i = n+1:1:2*n
    subplot(4,3,i-n)
    plot(t,x(:,i))
    state_num_text = sprintf('x_{%d}',i);
    ylabel(state_num_text);
    grid on
end

figure('Name','Position')
for i = 1:1:m
    subplot(3,3,i)
    plot(t,y(:,i))
    out_num_text = sprintf('y_{%d}',i);
    ylabel(out_num_text);
    grid on
end


[temp,lr] = size(r);
N_r_fig = ceil(lr/9);



f_count = 1;    %figure count
sp_count = 1;   %subplot count
for i = 1:1:lr
    figure(3+f_count)
    %idx = find(t>3,1);
    %max_r = max(abs(r(idx:length(r),i)));
    
    %if(max_r>0.005)
        subplot(3,3,sp_count);
        plot(t,r(:,i))
        ylabel(sprintf('r_{%d}',i))
        %ylim([-10 10])
        grid on
        
        f_count = f_count + floor(sp_count/9);
        sp_count = mod(sp_count,9)+1;
    %end
end

f_count2 = 1;    %figure count
sp_count = 1;   %subplot count

r_iso_lim = median( max(abs(r_isol),[],1));

for i = 1:1:m
    figure(3+f_count+f_count2)
    subplot(3,3,sp_count)
    plot(t,r_isol(:,i))
    out_num_text = sprintf('r''_{%d}',i);
    ylabel(out_num_text);
    %ylim([-r_iso_lim r_iso_lim])
    grid on
    
    f_count2 = f_count2 + floor(sp_count/9);
    sp_count = mod(sp_count,9)+1;
end



