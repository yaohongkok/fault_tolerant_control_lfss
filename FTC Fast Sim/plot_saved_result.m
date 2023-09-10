close all
t = xs.time;
x = xs.signals.values;
y = ys.signals.values;
r = rl_s.signals.values;
r_isol = r_isol_s.signals.values;
tn = linspace(0,6000,100);

%graph adjustment
% ta = t(1:28806);
% tb = t(28807:end)+60;
% tnew = linspace(2941,3000,30)';
% ya = y(1:28806,:);
% yb = y(28807:end,:);
% ynew = kron(y(28806,:),ones(30,1));
% 
% t2 = [ta;tnew;tb];
% y2 = [ya;ynew;yb];

t2 = t;
y2 = y;

figure('Name','Position')
hold on
plot(t2,y2(:,1),'LineWidth',2)
plot(tn,ones(1,100),'-.k');
text(3050,1.3,'y^{1}')
plot(t2,y2(:,2),'r','LineWidth',2);
plot(tn,2*ones(1,100),'-.k');
text(3050,2.3,'y^{2}')
plot(t2,y2(:,3),'m','LineWidth',2);
plot(tn,0.5*ones(1,100),'-.k');
text(3050,0.2,'y^{3}')
plot(t2,y2(:,4),'k','LineWidth',2);
plot(tn,-2*ones(1,100),'-.k');
text(2700,-1.8,'y^{4}')
p = plot(t2,y2(:,5),'LineWidth',2);
plot(tn,-3*ones(1,100),'-.k');
set(p,'Color',[0 0.5 0])
text(2700,-2.8,'y^{5}')
hold off
title('Output from LFSS [FTC using SRG]');
ylabel('y(t)');
xlabel('t (seconds)');
xlim([0 6000])
line([3000 3000],[-4,3],'Color',[0 0 0],'LineStyle','--','LineWidth',1.5)
text(3750,-0.7,'F_{u}^5 = 0')
annotation('arrow',[0.6 0.53],[0.5 0.5])
grid on

%[temp,lr] = size(r);
%N_r_fig = ceil(lr/9);

f_count2 = 1;    %figure count
sp_count = 1;   %subplot count

r_iso_lim = median( max(abs(r_isol),[],1));

figure(2)
for i = 1:1:m
    subplot(3,2,sp_count)
    plot(t,r_isol(:,i),'LineWidth',2)
    out_num_text = sprintf('$\\bar{r}^{%d}$',i);
    ylabel(out_num_text,'Interpreter','LaTex');
    ylim([-r_iso_lim r_iso_lim])
    set(gca,'Xtick',0:1000:6000)
    grid on
    
    f_count2 = f_count2 + floor(sp_count/9);
    sp_count = mod(sp_count,9)+1;
end
annotation('textbox',[0.43 0.953 0.4 0.04 ],'String','Structured Residual','LineStyle','none')

figure(3)
r_norm = zeros(length(r),1);

for i = 1:1:length(r)
    r_norm(i) = norm(r(i,:),2);
end

plot(t,r_norm)




