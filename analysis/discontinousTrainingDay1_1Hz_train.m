% for day1_5Hz_Train training
% created at Aug 8th 2017
clearvars;close all;
addpath ../include 
addpath ../analysis 
addpath ../V2P 


load ../V2P/day1_1Hz_Train.mat;

%day1_5Hz_Train contains 100 trips around ann ardor local region
%the trips are fine(but without filter/smoothing)
%attr = {'VID'1 'TripID'2 'Lat'3 'Long'4 'Elevation'5 'Speed'6 'Heading'7 ...
%    'Ax'8 'Ay'9 'Az'10 'Yawrate'11 'RadiusOfCurve'12 'Confidence'13 'Time'14};
%% setup training network config

% sample in 2Hz
% 4 sample delay (2s)
% use 10 samples as input
%load ../model/errMeasurement.mat;
errMeasurement = [];
checkpoint.current = 0;
checkpoint.count = 1;
checkpoint.save = 1;

trainParam.delayindex = 6;
trainParam.windowSize = 10;
trainParam.hiddenLayer = 5:5;
trainParam.randomSeed = 3:3;
trainParam.layerTransferFcn = 'tansig';
trainParam.trainFcn = 'trainlm';
trainParam.y_attr = [3 4];
trainParam.x_attr = [];
trainParam.numKFold = 4; 
trainParam.divideFcn = 'divideblock' ;
trainParam.divideParam.trainRatio = 80/100;
trainParam.divideParam.valRatio   = 20/100;
trainParam.divideParam.testRatio  = 0/100;
%trainParam.epochs = 2000-125*(netPara.windowSize-2);
trainParam.showWindow=1;
trainParam.max_fail=10;
trainParam.min_grad=1e-7;
trainParam.goal = 1e-9;

%day1_1Hz_Train = day1_1Hz_Train.trainningMode('UTM');
day1_1Hz_Train = day1_1Hz_Train.trainningMode('normal');
[errMeasurement,checkpoint] = day1_1Hz_Train.trainKFold(trainParam,errMeasurement,checkpoint);
%%
for i = 1:100
tripNum = i;
thistrip = day1_1Hz_Train.LocalTripCell{tripNum}(:,[3 4]);
lat = thistrip(:,1);
lng = thistrip(:,2);
f1= figure(1);
plot(lat,lng)
pause;
clear('f1');
end

%% training using segementation methodology
checkpoint.save = 1;
checkpoint.current = 0;
checkpoint.count = 1;
trainParam.checkpoint = checkpoint;
trainParam.layerTransferFcn = 'tansig';

trainParam.in_attr = [3 4]; 
trainParam.tar_delay = 3:3;
trainParam.windowSize = 5:5;
trainParam.randomSeed = 3:3;
trainParam.hiddenUnit = 10:10;
trainParam.mu = 0.01;
trainParam.epochs = 120;
trainParam.trainFcn = 'trainlm';
trainParam.performFcn = 'mse';
trainParam.divideFcn = 'divideblock' ;
divideParam.trainRatio = 0.75;
divideParam.valRatio = 0.25;
divideParam.testRatio = 0;
trainParam.divideParam = divideParam;
trainParam.showWindow=1;
trainParam.max_fail=10;
trainParam.min_grad=1e-7;
trainParam.goal = 1e-9;
trainParam.GPSMode = 'UTM';
trainParam.KFold = 4;
trainParam.K = 1;


day1_1Hz_Train = day1_1Hz_Train.trainningMode('UTM');
%%
%load ../model/errMeasurement.mat; 
errMeasurement = [];
[errMeasurement,checkpoint]=day1_1Hz_Train.trainSegKFold(trainParam,errMeasurement,checkpoint);
%%
[trainSet,testSet] = day1_1Hz_Train.genSegSet(trainParam);

%%
A = cell2mat(testSet.in_x);
B = cell2mat(testSet.in_y);
A = testSet.in_x{end};
B = testSet.in_y{end};
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
title([num2str(len) ' segments generated from trip ID 2449640 (2Hz,5s)']); 
%%
[Yt,Ytr,testerr] = day1_1Hz_Train.trainSeg(trainSet,testSet,trainParam);
%%
[trPredRe,trSetRe] = day1_1Hz_Train.retrieveGPSfromSeg(trainSet,Ytr,trainParam);
[tPredRe,tSetRe] = day1_1Hz_Train.retrieveGPSfromSeg(testSet,Yt,trainParam);
%%
idx = 20;
current = tSetRe.TripInCell{idx};
gt = tSetRe.GTCell{idx};
pred = tPredRe.TripInCell{idx};
tripLen = length(current(:,1));
tripIndex = testSet.idx(idx);
%[~,~,~]=day1_1Hz_Train.inspectTrip('TripIndex',tripIndex);
%%
windowSize = trainParam.windowSize;
featDim = length(trainParam.in_attr);
zoomRatio = 2;
mapType='roadmap';
timePause = 0.01;
figure('Name','plot prediction','pos',[80 100 1300 600])
subplot(2,4,[1 2 5 6]);
day1_1Hz_Train.inspectTrip('TripIndex',tripIndex,'addressOn',1,'getFigOnly','map');
hold off;
subplot(2,4,[3 4 7 8]);
title('current: blue | gt: green | pred: red');
hold on;
hc =[];
hgt = [];
hpr = [];
try
    for i = 1:tripLen
        if i == 1
            for j = 1:windowSize
                hc = [hc plot(current(1,j*2),current(1,j*2-1),'b.')];

                pause(0.1);
            end


            set(hc(end),'Marker','v','MarkerSize',10,'MarkerFaceColor','b');
            axis([gt(1,2)-0.003 gt(1,2)+0.003 gt(1,1)-0.003 gt(1,1)+0.003]);
                 plot_google_map('MapType','roadmap');
            hgt = plot(gt(1,2),gt(1,1),'g.');
            hpr = plot(pred(1,2),pred(1,1),'r.'); 
        else

            %1. plot current point
            hc = [hc plot(current(i,windowSize*featDim),current(i,windowSize*featDim-1),'b--.')];
            set(hc(end),'Marker','diamond','MarkerSize',10,'MarkerFaceColor','b');
            set(hc(end-1),'Marker','.','MarkerSize',6);
            %2. recolor past points > 
            set(hc(1:i-1),'Marker','.','MarkerSize',6,'Color',[0 0 0]);

            %3. highlight cur segment
            set(hc(i:i+windowSize-2),'Marker','s','MarkerSize',3,'MarkerFaceColor','b');       

            %4. plot gt
            hgt = [hgt plot(gt(i,2),gt(i,1),'g.')];
            set(hgt(end),'Marker','s','MarkerSize',8,'MarkerFaceColor','g');
            set(hgt(end-1),'Marker','.','MarkerSize',6,'MarkerFaceColor','none');
            %5. plot pred
            hpr = [hpr plot(pred(i,2),pred(i,1),'r.')];
            set(hpr(end),'Marker','^','MarkerSize',6,'MarkerFaceColor','r');
            set(hpr(end-1),'Marker','o','MarkerSize',2,'MarkerFaceColor','r');

            pause(timePause);        
            
            if mod(i,50/zoomRatio)==0
                axis([gt(i,2)-0.004/zoomRatio gt(i,2)+0.004/zoomRatio gt(i,1)-0.004*0.78/zoomRatio gt(i,1)+0.004*0.78/zoomRatio]);
                plot_google_map('MapType',mapType,'ShowLabels',1,'AutoAxis',0); 


            end
            %}

        end

    end
catch
            delete(f1);
            close all;
end
%%
idx = 5;
data = cell2mat(testSet.in_x);
groundt = cell2mat(testSet.in_y);
predout = Yt';
a1 = [];
a2 = [];
a3 = [];
figure(1); hold on;
axis([-200 200 -200 200]);
grid on;
for i = 654:3:10000
    a1 = [a1 plot(data(i,2:2:end),data(i,1:2:end),'s','Color',[0.7 0.7 0.7])];
    a2 = [a2 plot(groundt(i,2),groundt(i,1),'g.')];
    a3 = [a3 plot(predout(i,2),predout(i,1),'r.')];
    
    set(a1(end),'Color',[0.7 0.7 0.7],'LineWidth',5);
    set(a1(1:end-1),'LineStyle','-','Marker','none','Color',[0 0 0],'LineWidth',1);
   
    set(a2(end),'Marker','s','MarkerSize',6,'MarkerFaceColor','g');
    %set(a2(1:end-1),'Marker','.');
    set(a3(end),'Marker','v','MarkerSize',6,'MarkerFaceColor','r');
    %set(a3(1:end-1),'Marker','.');
    
     
    
    
    pause(0.01);
    
    
    %delete(a1(1:end));
      delete(a2(1:end));
       delete(a3(1:end));
  
    
    
end



%%
idx = 11;
in_x = YtrRe.TripInCell{idx};
in_y = trainSetRe.TripInCell{idx};
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
