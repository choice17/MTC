%% addpath
clc; clear; 
addpath ../analysis
addpath ../include
addpath ../include/day1TripObj
addpath ../include/VehicleFutPathPred
addpath ../include/utility

%% load model
%for freq 1Hz /deltaT = 3s/ windowSize = 5s / 2 attr only
%load ('../model/demoModel');
%for freq 1Hz /deltaT = 1s/ windowSize = 5s / 2 attr only
% model-net-GPS-2017-10-23_221310
%load ('../model/net-GPS-2017-10-23_221310.mat'); %lat/lng dt=1s nn=5 ws=5s 1Hz  
% model-net-GPS-2017-10-23_221310
%load ('../model/net-GPS-2018-01-02_201213.mat'); %lat/lng dt=1s nn=5 ws=5s 1Hz  
%for freq 2Hz /dt = 3s/ ws = 5s/ 5 attrs
%load ('../model/net-GPS-2017-12-24_043722.mat')
%for freq 2Hz /dt = 1s/ws = 5s/ 4 attrs
load ('../model/net-GPS-2017-12-30_015622.mat');
%for freq 2Hz /dt = 2s/ws = 5s/ 4 attrs
%load ('../model/net-GPS-2017-12-30_141607.mat');
%for freq 10Hz /dt = 0.5s/ws = 3s/ 4 attrs
load ('../model/net-GPS-2018-01-17_085114.mat');
%for freq 10Hz /dt = 1s/ws = 3s/ 4 attrs
load ('../model/net-GPS-2018-01-21_210350.mat');
load ('../model/net-GPS-2018-01-23_152157.mat');


model_in.model = net;
model_info.freq = 10;
model_info.deltaT = 10;
model_info.windowSize = 15;
model_info.attr = {'lat','lng','speed','heading'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);
% load dataset (demoTrip.mat is at 1Hz)
load('../data/demoTrip.mat');

%% prediction
[pred_GPS,errorMeasure,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    demoTrip.data{:,[1 2 4 5]});

%%
zoomRatio = 4;
mapType='satellite';
updateIter= 100;
timePause = 0.03;
figurePos = [300 100 950 700];
offset = 110;
vehiclePathPredObj.checkPredict('timePause',timePause,'zoomRatio',zoomRatio, ...
    'mapType',mapType,'updateIter',updateIter,'figurePos',figurePos,'offset',offset);
%% parameter to retrieve obd data

filename = '../data/OBD_DATA_Loop1PreTest&Test1.csv';
attrNum = [29 28 18 6 19 2 3 5 6 6 6 1];
attrName = {'lat','lng','elevation','speed','heading','ax','ay','az','dummy1','dummy2','dummy3','time'};
timeformat = 'yyyy/mm/dd HH:MM:SS';
timeRange = [datenum('2016/11/12 12:35:43',timeformat) ...
             datenum('2016/11/12 12:36:21',timeformat)];
samplingRate = 0.1;
demoTrip = readOBDdata(filename,attrNum,attrName,...
                        'samplingRate',samplingRate, ...
                        'timeRange',timeRange);
                    
%save('../data/demoTrip_2Hz.mat','demoTrip');
