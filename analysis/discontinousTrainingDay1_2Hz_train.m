% for day1_1Hz_Train training
% created at Aug 8th 2017
clearvars; clc;
addpath ../analysis
addpath ../include
addpath ../include/day1TripObj
addpath ../include/VehicleFutPathPred
addpath ../include/utility
%day1_1Hz_Train contains 100 trips around ann ardor local region
%the trips are fine(but without filter/smoothing)
%attr = {'VID'1 'TripID'2 'Lat'3 'Long'4 'Elevation'5 'Speed'6 'Heading'7 ...
%    'Ax'8 'Ay'9 'Az'10 'Yawrate'11 'RadiusOfCurve'12 'Confidence'13 'Time'14};
load ../data/day1_2Hz_Train.mat
%% setup training network config time series training %%%%%%%%%%%%%%%%%%%%

% sample in 1Hz
% 4 sample delay (2s)
% use 10 samples as input
% load ../model/errMeasurement.mat;
% initialze checkpoint 
errMeasurement = [];
checkpoint.current = 0;
checkpoint.count = 1;
checkpoint.save = 1;

% initialize training parameter 
trainParam.delayindex = 3;
trainParam.windowSize = 5;
trainParam.hiddenLayer = 5:5;
trainParam.randomSeed = 3:3;
trainParam.layerTransferFcn = 'tansig';
trainParam.trainFcn = 'trainscg';
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

day1_1Hz_Train = day1_1Hz_Train.trainningMode('UTM');
%day1_1Hz_Train = day1_1Hz_Train.trainningMode('normal');
[errMeasurement,checkpoint] = day1_2Hz_Train.trainKFold(trainParam,errMeasurement,checkpoint);

%% training using segementation methodology %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%checkpoint initialization
checkpoint.save = 1;
checkpoint.current = 12;
checkpoint.count = 1;
trainParam.checkpoint = checkpoint;

%network architecture initialization
trainParam.in_attr = [3 4]; 
trainParam.out_attr = [3 4];
trainParam.tar_delay = 2;
trainParam.windowSize = 2:2:10;
trainParam.randomSeed = 5;
trainParam.hiddenUnit = {[25];[30];[35]};
trainParam.layerTransferFcn = 'tansig';

%network training option selection
trainParam.mu = 0.01;
trainParam.epochs = 120;
trainParam.trainFcn = 'trainlm';
trainParam.performFcn = 'mse';
trainParam.max_fail=7;
trainParam.min_grad=1e-7;
trainParam.goal = 1e-9;
trainParam.regularization=0;

%network training option - divide function(training/val data setup)
trainParam.divideFcn = 'divideblock' ;
divideParam.trainRatio = 0.75;
divideParam.valRatio = 0.25;
divideParam.testRatio = 0;
trainParam.divideParam = divideParam;
trainParam.useParallel = 'yes';
%K-fold setup
trainParam.KFold = 4;
trainParam.K = 1;

%GPSMode setup
trainParam.GPSMode = 'UTM';

%flag to disp training process
trainParam.showWindow=1;

%turning the object to be ready for training
day1_2Hz_Train = day1_2Hz_Train.trainningMode('UTM');
clear divideParam
%% option to continue the log from errMeasurement.mat or renew training section

%load ../model/errMeasurement.mat; 
%errMeasurement = [];
[errMeasurement,checkpoint]=day1_2Hz_Train.trainSegKFold(trainParam,errMeasurement,checkpoint);
