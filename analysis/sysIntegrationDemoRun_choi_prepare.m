%%
clc; clear; 
addpath ../include;
addpath ../V2P;
addpath ../analysis;
%% original dataset attr
%attr = {'VID'1 'TripID'2 'Lat'3 'Long'4 'Elevation'5 'Speed'6 'Heading'7 ...
%    'Ax'8 'Ay'9 'Az'10 'Yawrate'11 'RadiusOfCurve'12 'Confidence'13 'Time'14};
%% obd data in ourdataset
%attr = {'lat'1, 'lng'2, 'elevation'3, 'speed'4, 'heading'5, 'Ax'6, 'Ay'7, ...
%    'Az'8,'dummy1'9,'dummy2'10,'dummy3'11,'time'12};

%% 2outputs
% freq = 2/dt = 6/ws = 10/'lat/lng/heading'
% load ('../model/sysdemo/net-GPS-2017-08-25_092434.mat '); %1
% freq = 2/dt = 6/ws = 10/'lat/lng'
%load ('../model/sysdemo/net-GPS-2017-08-28_153535.mat');
% freq = 1/dt = 3/ws = 5/'lat/lng/speed/heading'
  %load ('../model/sysdemo/net-GPS-2017-08-25_170516.mat');
% freq = 1/dt = 3/ws = 5/'lat/lng/
% load ('../model/sysdemo/net-GPS-2017-08-26_031518.mat');  %V1
% load ('../model/sysdemo/model-trainnet1f3s5wlatlng.mat'); %V2
% load ('../model/sysdemo/net-GPS-2017-08-26_154201.mat');    %V3
% load ('../model/sysdemo/net-GPS-2017-08-26_160600.mat');    %V4
% freq = 1/dt = 2/ws = 5/'lat/lng/
% load ('../model/sysdemo/net-GPS-2017-08-28_144027.mat');
% freq = 1/dt = 1/ws = 5/'lat/lng/
 load ('../model/sysdemo/net-GPS-2017-08-28_145726.mat');

%% 4output net
% freq = 1/dt = 3/ws = 5/'lat/lng/spd/heading
load ('../model/sysdemo/net-GPS-2017-09-08_064330.mat');
%%
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
load('../V2P/day1_1Hz_demoTrain.mat');
%%
timespend = zeros(1,1000);
for i = 1:1000
tic;    
[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    demoTrip.data{1:5,[1 2]});
timespend(i) = toc;
end
%[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
%    day1_1Hz_Train.TripInCell{1}(500:end,[3 4]));
%[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
%    thisTrip.data);
%[A,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
%    day1_1Hz_demoTrain.TripInCell{90}(2240:end,[3 4]));
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
zoomRatio = 3;
mapType='satellite';
updateIter= 50;
timePause = 0.1;
figurePos = [300 100 950 700];
offset =1;
showDirection = 1;
showSpeed = 1;

vehiclePathPredObj.checkPredict('timePause',timePause,'zoomRatio',zoomRatio, ...
    'mapType',mapType,'updateIter',updateIter,'figurePos',figurePos,'offset',offset,...
    'showDirection',showDirection,'showSpeed',showSpeed);
%% from sys integrate demo 
filename = '../V2P/OBD_DATA_Loop1PreTest&Test1.Csv';
%filename = '../V2P/OBD_DATA_Loop3.Csv';
attrNum = [29 28 18 6 19 2 3 5 6 6 6 1];
attrName = {'lat','lng','elevation','speed','heading','ax','ay','az','dummy1','dummy2','dummy3','time'};
%attrNum = [29 28 19 1];
%attrName = {'lat','lng','heading','time'};
timeformat = 'yyyy/mm/dd HH:MM:SS';
timeRange = [datenum('2016/11/12 12:35:43',timeformat) ...
             datenum('2016/11/12 12:36:21',timeformat)];
%timeRange = [datenum('2016/11/12 15:13:32',timeformat) ...
%            datenum('2016/11/12 15:19:32',timeformat)];         
samplingRate = 0.01;
demoTrip = readOBDdata(filename,attrNum,attrName,...
                        'samplingRate',samplingRate, ...
                        'timeRange',timeRange);
%%
plot(demoTrip.data{:,2},demoTrip.data{:,1},'r-','LineWidth',2);
plot_google_map('mapType','satellite');

%%
figure(2);
plot(pedes(:,2),pedes(:,1),'b.');
hold on;
plot(pedes(1,2),pedes(1,1),'bo');
