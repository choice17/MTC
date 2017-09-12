% for day1_5Hz_Train training
% created at Aug 8th 2017
clearvars;close all;
addpath ../include 
addpath ../analysis 
addpath ../V2P 


%load ../V2P/day1_1Hz_demoTrain.mat;
load ../V2P/day1_1Hz_demoTrain.mat;
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

trainParam.delayindex = 3;
trainParam.windowSize = 5;
trainParam.hiddenLayer = 5:5;
trainParam.randomSeed = 3:3;
trainParam.layerTransferFcn = 'tansig';
trainParam.trainFcn = 'trainlm';
trainParam.y_attr = [3 4 6 7];
trainParam.x_attr = [6 7];
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

%day1_1Hz_demoTrain = day1_1Hz_demoTrain.trainningMode('UTM');
day1_1Hz_demoTrain = day1_1Hz_demoTrain.trainningMode('normal');
[errMeasurement,checkpoint] = day1_1Hz_demoTrain.trainKFold(trainParam,errMeasurement,checkpoint);
%%
for i = 1:100
tripNum = i;
thistrip = day1_1Hz_demoTrain.LocalTripCell{tripNum}(:,[3 4]);
lat = thistrip(:,2);
lng = thistrip(:,1);
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

trainParam.in_attr = [3 4 6 7]; 
trainParam.out_attr = [3 4 6 7];
trainParam.tar_delay = 1:1;
trainParam.windowSize = 5:5;
trainParam.randomSeed = 1:5;
trainParam.hiddenUnit = {[30]};
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
trainParam.regularization=0;

day1_1Hz_demoTrain = day1_1Hz_demoTrain.trainningMode('UTM');
%%
%load ../model/errMeasurement.mat; 
errMeasurement = [];
[errMeasurement,checkpoint]=day1_1Hz_demoTrain.trainSegKFold(trainParam,errMeasurement,checkpoint);
%%
trainParam.randomSeedIdx = 6;
[trainSet,testSet] = day1_1Hz_demoTrain.genSegSet(trainParam);

%%
thisset = trainSet;
A = cell2mat(thisset.in_x);
B = cell2mat(thisset.in_y);
thistripID = 18;
A = thisset.in_x{thistripID};
B = thisset.in_y{thistripID};
len = length(A(:,1));
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
title([num2str(len) ' segments generated from trip ID ' num2str(day1_1Hz_demoTrain.getTripID('TripIndex',thistripID)) ' (1Hz,5s)']); 
%%
[Yt,Ytr,testerr] = day1_1Hz_demoTrain.trainSeg(trainSet,testSet,trainParam);
%%
[trPredRe,trSetRe] = day1_1Hz_demoTrain.retrieveGPSfromSeg(trainSet,Ytr,trainParam);
[tPredRe,tSetRe] = day1_1Hz_demoTrain.retrieveGPSfromSeg(testSet,Yt,trainParam);
%%
trainParam.curveRatioThresh = 0.5;
[trainSet,curveRatio,idx] = curveExtraction(trainSet,trainParam);


%%
idx = 7;
thisSetRe = tSetRe;
thisPredRe = tPredRe;
current_o = thisSetRe.TripInCell{idx};
gt_o = thisSetRe.GTCell{idx};
pred_o = thisPredRe.TripInCell{idx};
tripIndex = thisSetRe.idx(idx);

%[~,~,~]=day1_1Hz_demoTrain.inspectTrip('TripIndex',tripIndex);
%%
windowSize = trainParam.windowSize;
%featDim = length(trainParam.in_attr);
featDim=2;
zoomRatio = 3;
mapType='satellite';
timePause = [];
offset = 2240;
figure('Name','plot prediction','pos',[80 100 1300 600])
subplot(2,4,[1 2 5 6]);
day1_1Hz_demoTrain.inspectTrip('TripIndex',tripIndex,'addressOn',0,'getFigOnly','map');

hold off;
subplot(2,4,[3 4 7 8]);
updateIter = 50;
title('current: blue | gt: green | pred: red');
hold on;
hc =[];
hgt = [];
hpr = [];
current = current_o(offset:end,:);
gt = gt_o(offset:end,:);
pred = pred_o(offset:end,:);
tripLen = length(gt(:,1))


%try
    for i = 1:tripLen
        if i == 1
            for j = 1:windowSize
                hc = [hc plot(current(1,j*2),current(1,j*2-1),'b.')];

                pause(0.1);
            end


            set(hc(end),'Marker','v','MarkerSize',10,'MarkerFaceColor','b');
           axis([gt(i,2)-0.004/zoomRatio gt(i,2)+0.004/zoomRatio ...
               gt(i,1)-0.004*0.78/zoomRatio gt(i,1)+0.004*0.78/zoomRatio]);
                 plot_google_map('MapType',mapType);
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
            if isempty(timePause)                
                pause();   
            else 
                pause(timePause);
                i
            end
            
            if mod(i,updateIter)==0
                axis([gt(i,2)-0.004/zoomRatio gt(i,2)+0.004/zoomRatio gt(i,1)-0.004*0.78/zoomRatio gt(i,1)+0.004*0.78/zoomRatio]);
                plot_google_map('MapType',mapType,'ShowLabels',1,'AutoAxis',0); 


            end
            %}

        end

    end
%catch
%            delete(f1);
%            close all;
%end
%%
idx = 7;
thisset = testSet;
data = thisset.in_x{idx};
groundt = thisset.in_y{idx};

idxStart = sum(cellfun(@(x) size(x,1),thisset.in_y(1:idx-1)))+1;
predidx = [idxStart:idxStart+size(thisset.in_y{idx},1)];

predout = Ytr(:,predidx)';
a1 = [];
a2 = [];
a3 = [];
figure(5); hold on;
axis([-100 100 -100 100]);
grid on;
timePause = [];
for i = 1:10000
    a1 = [a1 plot(data(i,2:2:end),data(i,1:2:end),'s','Color',[0.7 0.7 0.7])];
    a2 = [a2 plot(groundt(i,2),groundt(i,1),'g.')];
    a3 = [a3 plot(predout(i,2),predout(i,1),'r.')];
    
    set(a1(end),'Color',[0.7 0.7 0.7],'LineWidth',5);
    set(a1(1:end-1),'LineStyle','-','Marker','none','Color',[0 0 0],'LineWidth',1);
   
    set(a2(end),'Marker','s','MarkerSize',6,'MarkerFaceColor','g');
    %set(a2(1:end-1),'Marker','.');
    set(a3(end),'Marker','v','MarkerSize',6,'MarkerFaceColor','r');
    %set(a3(1:end-1),'Marker','.');
    
     
    
    if isempty(timePause)
        pause();
    else
        pause(timePause);
    end
    
    
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



