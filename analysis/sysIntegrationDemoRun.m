%% addpath
clc; clear; 
addpath ../include;
addpath ../V2P;
addpath ../analysis;
%% load model
%for freq 1Hz /deltaT = 3s/ windowSize = 5s / 2 attr only
load ('../model/sysdemo/demoModel');

model_in.model = net;
model_info.freq = 1;
model_info.deltaT = 3;
model_info.windowSize = 5;
model_info.attr = {'lat','lng','speed','heading'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);
% load dataset
load('../V2P/demoTrip.mat');

%% prediction
[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    demoTrip.data{:,[1 2]});

%%
zoomRatio = 1;
mapType='satellite';
updateIter= 50;
timePause = [];
figurePos = [300 100 950 700];

vehiclePathPredObj.checkPredict('timePause',timePause,'zoomRatio',zoomRatio, ...
    'mapType',mapType,'updateIter',updateIter,'figurePos',figurePos);
%% parameter to retrieve obd data

filename = '../V2P/OBD_DATA_Loop1PreTest&Test1.Csv';
attrNum = [29 28 18 6 19 2 3 5 6 6 6 1];
attrName = {'lat','lng','elevation','speed','heading','ax','ay','az','dummy1','dummy2','dummy3','time'};
timeformat = 'yyyy/mm/dd HH:MM:SS';
timeRange = [datenum('2016/11/12 12:35:43',timeformat) ...
             datenum('2016/11/12 12:36:21',timeformat)];
samplingRate = 0.01;
demoTrip = readOBDdata(filename,attrNum,attrName,...
                        'samplingRate',samplingRate, ...
                        'timeRange',timeRange);

