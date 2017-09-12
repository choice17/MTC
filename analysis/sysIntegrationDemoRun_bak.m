%%
clc; clear; 
addpath ../include;
addpath ../V2P;
addpath ../analysis;
%%
% freq = 2/dt = 6/ws = 10/'lat/lng/heading'
% load ('../model/sysdemo/net-GPS-2017-08-25_092434.mat '); %1
% freq = 2/dt = 6/ws = 10/'lat/lng'
%load ('../model/sysdemo/net-GPS-2017-08-28_153535.mat');
% freq = 1/dt = 3/ws = 5/'lat/lng/speed/heading'
  %load ('../model/sysdemo/net-GPS-2017-08-25_170516.mat');
% freq = 1/dt = 3/ws = 5/'lat/lng/
 load ('../model/sysdemo/net-GPS-2017-08-26_031518.mat');  %V1
% load ('../model/sysdemo/model-trainnet1f3s5wlatlng.mat'); %V2
% load ('../model/sysdemo/net-GPS-2017-08-26_154201.mat');    %V3
% load ('../model/sysdemo/net-GPS-2017-08-26_160600.mat');    %V4
% freq = 1/dt = 2/ws = 5/'lat/lng/
% load ('../model/sysdemo/net-GPS-2017-08-28_144027.mat');
% freq = 1/dt = 1/ws = 5/'lat/lng/
%load ('../model/sysdemo/net-GPS-2017-08-28_145726.mat');

model_in.model = net;
model_info.freq = 1;
model_info.deltaT = 3;
model_info.windowSize = 5;
model_info.attr = {'lat','lng'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);
%%
load('../V2P/day1_1Hz_Train.mat');
load('../V2P/day1_2Hz_Train.mat');

%load('../V2P/demoTrip.mat');

%%
[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    demoTrip.data{:,[1 2]});
%[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
%    day1_1Hz_Train.TripInCell{1}(500:end,[3 4]));
%[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
%    thisTrip.data);
[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    day1_1Hz_demoTrain.TripInCell{90}(2240:end,[3 4]));
%%
%[Xt,Yt]=vehiclePathPredObj.genSeg(demoTrip.data{:,[1 2]});
[Xt,Yt]=vehiclePathPredObj.genSeg(day1_1Hz_demoTrain.TripInCell{90}(:,[3 4]));
%%
net = vehiclePathPredObj.getmodel();
net.trainParam.mu = 0.001;
net.trainParam.mu_inc = 1.2;
net.trainParam.mu_dec = 0.1;
net.trainParam.max_fail = 200;
net.trainParam.epochs = 500;
net.trainParam.showWindow = 1;
net = train(net,Xt.featureCell(1:end-3,:)',Yt');


%%
zoomRatio = 1;
mapType='satellite';
updateIter= 50;
timePause = [];
figurePos = [300 100 950 700];

vehiclePathPredObj.checkPredict('timePause',timePause,'zoomRatio',zoomRatio, ...
    'mapType',mapType,'updateIter',updateIter,'figurePos',figurePos);
%% from sys integrate demo 
filename = '../V2P/OBD_DATA_Loop1PreTest&Test1.Csv';
attrNum = [29 28 18 6 19 2 3 5 6 6 6 1];
attrName = {'lat','lng','elevation','speed','heading','ax','ay','az','dummy1','dummy2','dummy3','time'};
%attrNum = [29 28 19 1];
%attrName = {'lat','lng','heading','time'};
timeformat = 'yyyy/mm/dd HH:MM:SS';
%timeRange = [datenum('2016/11/12 12:35:43',timeformat) ...
%             datenum('2016/11/12 12:36:21',timeformat)];
%timeRange = [datenum('2016/11/12 12:27:43',timeformat) ...
%             datenum('2016/11/12 12:39:21',timeformat)];         
samplingRate = 0.01;
demoTrip = readOBDdata(filename,attrNum,attrName,...
                        'samplingRate',samplingRate, ...
                        'timeRange',timeRange);
%%

A = dlmread('test.csv',',',[2 0 2 3])

