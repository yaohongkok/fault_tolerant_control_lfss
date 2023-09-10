close all
t = xs.time;
x = xs.signals.values;
y = ys.signals.values;
%r_isol = r_isol_s.signals.values;

tn = linspace(0,6000,100);

figure('Name','Position')
hold on
plot(t,y(:,1),'LineWidth',2)
plot(tn,ones(1,100),'-.k');
text(3050,1.3,'y_{1}')
plot(t,y(:,2),'r','LineWidth',2);
plot(tn,2*ones(1,100),'-.k');
text(3050,2.3,'y_{2}')
plot(t,y(:,3),'m','LineWidth',2);
plot(tn,0.5*ones(1,100),'-.k');
text(3050,0.2,'y_{3}')
plot(t,y(:,4),'k','LineWidth',2);
plot(tn,-2*ones(1,100),'-.k');
text(2700,-1.8,'y_{4}')
p = plot(t,y(:,5),'LineWidth',2);
plot(tn,-3*ones(1,100),'-.k');
set(p,'Color',[0 0.5 0])
text(2700,-2.8,'y_{5}')
hold off
title('Output from LFSS [FTC using Huang''s FD algorithm]');
ylabel('y(t)');
xlabel('t (seconds)');
line([3000 3000],[-4,3],'Color',[0 0 0],'LineStyle','--','LineWidth',1.5)
text(3750,-0.7,'F_{u}^5 = 0')
annotation('arrow',[0.6 0.53],[0.5 0.5])
grid on

%[temp,lr] = size(r);
%N_r_fig = ceil(lr/9);

% f_count2 = 1;    %figure count
% sp_count = 1;   %subplot count
% 
% r_iso_lim = median( max(abs(r_isol),[],1));
% 
% figure(2)
% for i = 1:1:m
%     subplot(3,3,sp_count)
%     plot(t,r_isol(:,i))
%     out_num_text = sprintf('r''_{%d}',i);
%     ylabel(out_num_text);
%     ylim([-r_iso_lim r_iso_lim])
%     grid on
%     
%     f_count2 = f_count2 + floor(sp_count/9);
%     sp_count = mod(sp_count,9)+1;
% end



