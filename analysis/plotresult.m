option.Index = 'TripIndex';
option.Operation = 'keep';
index = 1:40;
day1_2Hz_Train = day1_2Hz_Train.removeTripByID(option,index);
%%
idx= 500;
figure;
while (1)

plot(in_x{1}(idx,1:10:end),in_x{1}(idx,2:10:end)); hold on;
%plot(in_y{1}(idx,1),in_y{1}(idx,2),'rx')
idx = idx+1;
pause();
end
%%
idx= 1;
figure;
while (1)

plot(in_x{1}(idx,2:10:end),in_x{1}(idx,1:10:end)); hold on;
%plot(in_y{1}(idx,1),in_y{1}(idx,2),'rx')
idx = idx+1;
pause();
end
%%
idx=1;
figure;
while (1)

plot(in_x_Seg{1}(idx,2:2:end),in_x_Seg{1}(idx,1:2:end),'bx'); hold on;

idx = idx+1;
pause();
end
%plot(in_y{1}(idx,1),in_y{1}(idx,2),'rx')
%%
figure;
plot(in_x{1}(:,2),in_x{1}(:,1)); hold on;
%plot(in_y{1}(idx,1),in_y{1}(idx,2),'rx')
plot_google_map('mapType','roadmap')
%%
figure(10)

plot(in_y{29}(:,2),in_y{29}(:,1)); hold on;
%% 1Hz vs 2Hz t+1s
x1 = [5 10 15 20 25 30; 0.4809520242 0.464266206 0.459712653 0.457964987 ...
    0.456652383 0.467162212];
x2 = [5 10 15 20 25 30; 0.56151557 0.559612405 0.564233008 0.562228517 ...
0.561991286 0.558634783];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);

set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)

grid on;
hold off;
legend({'2Hz,GPS','1Hz,GPS'}, ...
    'Location','best');
axis([5 30 0.3 0.58])
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('1Hz vs 2Hz, t+1(s) prediction')

%% 1Hz vs 2Hz t+2s
x1 = [5 10 15 20 25 30; 1.43005082 1.396625032 1.386532152 1.387883283 ...
    1.383199304 1.4000320456];
x2 = [5 10 15 20 25 30; 1.606117779 1.597265479 1.595176194 1.590585102 ...
1.593213196 1.605146452];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);

set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)

grid on;
hold off;
legend({'2Hz,GPS','1Hz,GPS'}, ...
    'Location','best');
axis([5 30 0.8 1.65 ])
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('1Hz vs 2Hz, t+2(s) prediction')

%% 1Hz vs 2Hz t+3s
x1 = [5 10 15 20 25 30; 2.909560631 2.864278524 2.828226749 2.836341244 ...
    2.824659545 2.870200599];
x2 = [5 10 15 20 25 30; 3.205750333 3.215075942 3.173128202 3.164520091 ...
3.179011863 3.223867568];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);

set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)

grid on;
hold off;
legend({'2Hz,GPS','1Hz,GPS'}, ...
    'Location','best');
axis([5 30 1.8 3.3 ])
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('1Hz vs 2Hz, t+3(s) prediction')


%% 2Hz t+1s
x1 = [5 10 15 20 25 30; 0.471775483 0.456932773 0.447180976 0.44517312 ...
0.455209662 0.450498406 ];
x2 = [5 10 15 20 25 30; 0.458375797 0.441506137 0.454871949 0.413998981 ...
0.421116416 0.412281864 ];
x3 = [5 10 15 20 25 30; 0.4809520242 0.464266206 0.459712653 0.457964987 ...
    0.456652383 0.467162212];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);
h3 = plot(x3(1,:),x3(2,:),'o--','LineWidth',2);
set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)
set(h3,'MarkerFaceColor',h3.Color)
grid on;
hold off;
legend({'GPS, Speed, Heading, YawRate','GPS, Speed, Heading','GPS'})
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('2Hz, t+1(s) prediction')
%% 2Hz t+2s
x1 = [5 10 15 20 25 30; 1.384946302 1.355629943 1.220694155 1.240161082 ...
1.22924076 1.21923668 ];
x2 = [5 10 15 20 25 30; 1.374536257 1.28640687 1.227567012 1.205338614 ...
1.197241095 1.177955167 ];
x3 = [5 10 15 20 25 30; 1.43005082 1.396625032 1.386532152 1.387883283 ...
    1.383199304 1.4000320456];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);
h3 = plot(x3(1,:),x3(2,:),'o--','LineWidth',2);
set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)
set(h3,'MarkerFaceColor',h3.Color)
grid on;
hold off;
legend({'GPS, Speed, Heading, YawRate','GPS, Speed, Heading','GPS'}, ...
    'Location','best')
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('2Hz, t+2(s) prediction')
%% 2Hz t+3s
x1 = [5 10 15 20 25 30; 2.798675101 2.688993469 2.578313753 2.492438835 ...
2.6019875 2.501176889 ];
x2 = [5 10 15 20 25 30; 2.806187513 2.644402792 2.549300965 2.514244177 ...
2.518727003 2.542273608];
x3 = [5 10 15 20 25 30; 2.909560631 2.864278524 2.828226749 2.836341244 ...
    2.824659545 2.870200599];


figure(1);
h1 = plot(x1(1,:),x1(2,:),'o--','LineWidth',2);hold on;
h2 = plot(x2(1,:),x2(2,:),'o--','LineWidth',2);
h3 = plot(x3(1,:),x3(2,:),'o--','LineWidth',2);
set(h1,'MarkerFaceColor',h1.Color)
set(h2,'MarkerFaceColor',h2.Color)
set(h3,'MarkerFaceColor',h3.Color)
grid on;
hold off;
legend({'GPS, Speed, Heading, YawRate','GPS, Speed, Heading','GPS'}, ...
    'Location','best');
xlabel('# of hidden unit');
ylabel('K-fold error(m)')
title('2Hz, t+3(s) prediction')

