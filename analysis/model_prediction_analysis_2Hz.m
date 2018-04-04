%% Algorithm checking, model analysis

%clearvars; clc;
addpath ../analysis
addpath ../include
addpath ../include/day1TripObj
addpath ../include/VehicleFutPathPred
addpath ../include/utility

load ../data/day1_2Hz_Train.mat;
%% load a pretrained model
%load ../model/net-GPS-2017-10-02_225056.mat %lat/lng dt=3s nn5-5 ws=5s
%load ../model/net-GPS-2017-10-02_225925.mat %lat/lng/spd/hd dt=3s nn5-5 ws=5s
%load ../model/net-GPS-2017-10-05_173901.mat %lat/lng dt=3s nn5-5 ws=5s 2Hz
%load ('../model/net-GPS-2017-08-28_145726.mat'); %lat/lng dt=1s nn=5 ws=5s 2Hz 
%load ('../model/net-GPS-2017-10-23_221310.mat'); %lat/lng dt=1s nn=5 ws=5s 2Hz  
%load ('../model/net-GPS-2017-12-24_043722.mat'); %gps/spd/heading/yaw dt=3s nn=30 ws=5s 2Hz
load ('../model/net-GPS-2017-08-16_035936.mat');%gps dt=1s nn=25, ws=5s 2Hz

view(net);
day1_2Hz_Train = day1_2Hz_Train.setModel(net);
day1_2Hz_Train = day1_2Hz_Train.setTrainParam(trainParam);
day1_2Hz_Train = day1_2Hz_Train.trainningMode('UTM');

%% segmentation process observation

[trPredRe,trSetRe,trainSet,Ytr] = day1_2Hz_Train.modelPredict();
%% observe test set segment

    A = trainSet.in_x{1};
    B = trainSet.in_y{1};
    len = length(B(:,1));
    figure(1);
    hold on;
    for i = 1:1:len
        plot(A(i,2:2:end),A(i,1:2:end));
        %plot(B(i,2),B(i,1),'r.');
        %pause(0.01)
    end
    hold off;
    xlabel('x-axis (m)');
    ylabel('y-axis (m)');
    title([num2str(len) ' segments generated from trip  (2Hz,5s)']); 

%% prediction on all the trips in dataset

[trPredRe,trSetRe,trainSet,Ytr,day1_2Hz_Train] = day1_2Hz_Train.modelPredict();

%% error analysis: histogram on the error distribution

errorbin = cell2mat(trPredRe.triperrbin);
histogram(errorbin,100);
xlabel('error in meter');
ylabel('counts');
title('error distribution in histogram');


%% check the predicted route on the dataset by plotting
idx= 1;
option.zoomRatio = 1;
option.update = 30;
option.mapType = 'roadmap';
option.offset= 20;
option.timePause= 0.1;

day1_2Hz_Train.checkPredictError(option,idx)



%% display the segment output

data =cell2mat(trainSet.in_x);
groundt = cell2mat(trainSet.in_y);
predout = Ytr';
a1 = [];
a2 = [];
a3 = [];
figure(1); hold on;
axis([-200 200 -200 200]);
grid on;
for i = 2000:2:10000
    a1 = [a1 plot(data(i,2:2:end),data(i,1:2:end),'s','Color',[0.7 0.7 0.7])];
    a2 = [a2 plot(groundt(i,2),groundt(i,1),'g.')];
    a3 = [a3 plot(predout(i,2),predout(i,1),'r.')];
    
    set(a1(end),'Color',[0.7 0.7 0.7],'LineWidth',5);
    set(a1(1:end-1),'LineStyle','-','Marker','none','Color',[0 0 0],'LineWidth',1);
   
    set(a2(end),'Marker','s','MarkerSize',6,'MarkerFaceColor','g');
    %set(a2(1:end-1),'Marker','.');
    set(a3(end),'Marker','v','MarkerSize',6,'MarkerFaceColor','r');
    %set(a3(1:end-1),'Marker','.');
    
     
    
    
    pause(0.05);
    
    
    %delete(a1(1:end));
      delete(a2(1:end));
       delete(a3(1:end));
  
    
    
end



%% display the segment gt
idx = 11;
in_x = trainSet.in_x{idx};
in_y = trainSet.in_y{idx};
data = in_x;
tar = in_y;
gt = [in_x];

figure(1); hold on;
for i = 1:10000
    plot(data(i,2:2:end),data(i,1:2:end));
    plot(tar(i,2),tar(i,1),'g.');
   
    
    if mod(i,10)==0
        
        a1 = [];
        a2 = [];
        a3 = [];
    end
    
    
    pause(0.1)
end
