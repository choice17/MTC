% DSRC analysis
%% addpath
clc; clear; 
addpath ../analysis
addpath ../include
addpath ../include/day1TripObj
addpath ../include/VehicleFutPathPred
addpath ../include/utility
%% import data 
%rawData = xlsread('../data/DSRC/DSRC_test_9-29-2017.xlsx');
rawData = xlsread('../data/DSRC/Song_Choi_11_10_2017.xlsx');
docEndRow = 5624;
rawData = rawData(1:docEndRow-1,2:end);
rawData(:,2) =rawData(:,2);
rawData(:,5) =rawData(:,5);
rawData(:,6) =rawData(:,6);
rawData(:,10) =rawData(:,10);
%% load time stamp
[timePiSent,t1] = unixTimeConv(rawData(:,2))   ;
[timeSRec,t2]   = unixTimeConv(rawData(:,5))   ;
[timeSSent,t3]  = unixTimeConv(rawData(:,6))   ;
[timePiRec,t4]  = unixTimeConv(rawData(:,10))  ;
rawDataRow = length(rawData(:,1));
timeCharLen = length(timePiSent(1,:));
DSRCtimestamp =  [mat2cell(timePiSent,ones(rawDataRow,1),timeCharLen), mat2cell(timeSRec,ones(rawDataRow,1),timeCharLen), ...
    mat2cell(timeSSent,ones(rawDataRow,1),timeCharLen), mat2cell(timePiRec,ones(rawDataRow,1),timeCharLen)];
%unixTime = rawData(:,4);
unixTime = rawData(:,5);
%% DSRC package return latency
timearray = ((t2-t1)+(t4-t3))./2;
mt = mean(((t2-t1)+(t4-t3))./2);
DSRC_latency = datestr(mt,'SS.FFF');
fprintf('mean DSRC_latency is %s second \n',DSRC_latency);

%% keep time stamp of package sent from Pi only

% resample the dataset to uniform 10 Hz
%check timestamp
timestamp = unixTime-unixTime(1);
diff_time = sort(diff(timestamp));

pedestrian_data = [rawData(:,[3 4]) timestamp];
vehicle_data = [rawData(:,[7 8]) timestamp];

% display data in the map
plot(pedestrian_data(:,2),pedestrian_data(:,1),'b-'); hold on;
plot(vehicle_data(:,2),vehicle_data(:,1),'r-');
plot_google_map;
% for i = 2815:1:2825
%     text(vehicle_data(i,2)+0.000002,vehicle_data(i,1)+0.000002,num2str(i));
%     plot(vehicle_data(i,2),vehicle_data(i,1),'o');
% end

Len = length(vehicle_data(:,1));

% text(pedestrianData(idxRange,2)+0.00002,pedestrianData(idxRange,1)+0.00002, ...
%     mat2cell(num2str(idxRange'),ones(length(idxRange),1)));
text(vehicle_data([1 end],2)+0.00006,vehicle_data([1 end],1)+0.00002, ...
    {'\leftarrow Vehicle Start','End'},'Color','r','FontSize',12);
text(pedestrian_data([1 end],2)+0.00002,pedestrian_data([1 end],1)+0.00002, ...
    {'\leftarrow Pedestrian Start','End'},'Color','b','FontSize',12);
%% by observe the data manually, we can see the data is good since index 1901
% crop the data from 1901 idx
% for 10-26 DSRC
% segment1: 1761:2236 - 47s
% segment2: 2360:2580 - 22s
% segment3: 2585:2780 - 20s
% segment4: 2790:3785 - 99s
% segment5: 3790:3970 - 18s
% segment6: 3975:4280 - 31s
% segment7: 4285:4700 - 42s

close all;
idx = 1500:4500;
pedestrian_crop_data = pedestrian_data(idx,:);
vehicle_crop_data = vehicle_data(idx,:);
timestamp_crop = timestamp(idx,:);
t1_crop = t1(idx,:);

%% plot the cropped data
plot(pedestrian_crop_data(:,2),pedestrian_crop_data(:,1),'b-'); hold on;
plot(vehicle_crop_data(:,2),vehicle_crop_data(:,1),'ro-');
plot_google_map('mapType','satellite');
Len = length(vehicle_crop_data(:,1));
idxRange = 1:5:Len;
text(vehicle_crop_data(idxRange,2)+0.00002,vehicle_crop_data(idxRange,1)+0.00002, ...
    mat2cell(num2str(idxRange'),ones(length(idxRange),1)));

%% resample data
Fs = 10;
p=1;
q=1;
range = 1:1000;
vehicleData = [];
pedestrianData = [];
for i=1:2
    vehicleData = [vehicleData resample(vehicle_crop_data(:,i),timestamp_crop,Fs,1,1)];
    pedestrianData = [pedestrianData resample(pedestrian_crop_data(:,i),timestamp_crop,Fs,1,1)];
end
%% downsample to 1Hz
windowSize = 21;
alg = 'moving';
resampleRate = 1;
vehicleData = [smooth(vehicleData(:,1),windowSize,alg) smooth(vehicleData(:,2),windowSize,alg)];
vehicleData = vehicleData(1:1/resampleRate:end,:);

pedestrianData = [smooth(pedestrianData(:,1),windowSize,alg) smooth(pedestrianData(:,2),windowSize,alg)];
pedestrianData = pedestrianData(1:1/resampleRate:end,:);
%% plot downsample 

plot(pedestrianData(:,2),pedestrianData(:,1),'b-'); hold on;
plot(vehicleData(:,2),vehicleData(:,1),'ro-');
plot_google_map;
Len = length(vehicleData(:,1));
idxRange = 1:100:Len;
% text(pedestrianData(idxRange,2)+0.00002,pedestrianData(idxRange,1)+0.00002, ...
%     mat2cell(num2str(idxRange'),ones(length(idxRange),1)));
text(vehicleData(idxRange,2)+0.00006,vehicleData(idxRange,1)+0.00002, ...
    mat2cell(num2str(idxRange'),ones(length(idxRange),1)));
text(vehicleData([1 end],2)+0.00006,vehicleData([1 end],1)+0.00002, ...
    {'\leftarrow Vehicle Start','End'},'Color','b','FontSize',12);
text(pedestrianData([1 end],2)+0.00002,pedestrianData([1 end],1)+0.00002, ...
    {'\leftarrow Pedestrian Start','End'},'Color','b','FontSize',12);
%% time reshape
tripLen = length(pedestrianData(:,1));
t1Reshape = repmat(t1_crop(1),tripLen,1)+[0:tripLen-1]'.*1/86400;
timestampReshape = 0:tripLen-1;
%% load model
load ('../model/net-GPS-2017-08-28_145726.mat');

model_in.model = net;
model_info.freq = 1;
model_info.deltaT = 1;
model_info.windowSize = 5;
model_info.attr = {'lat','lng'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);
%% 2 Hz
load ('../model/net-GPS-2017-12-30_015622.mat')
% 
model_in.model = net;
model_info.freq = 2;
model_info.deltaT = 2;
model_info.windowSize = 5;
model_info.attr = {'lat','lng','speed','heading'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);

%% 10Hz
load ('../model/net-GPS-2017-11-09_210347.mat');
% 
model_in.model = net;
model_info.freq = 10;
model_info.deltaT = 10;
model_info.windowSize = 30;
model_info.attr = {'lat','lng'};
model_in.model_info = model_info;
vehiclePathPredObj = VehicleFutPathPred(model_in);



%% prediction
[pred_GPS,errorMeasure,vehiclePathPredObj] = vehiclePathPredObj.pathPredict( ...
    vehicleData);

%%
zoomRatio = 4;
mapType='satellite';
updateIter= 100;
timePause = 0.05;
figurePos = [300 100 950 700];
AutoAxis = 0;
offset = 1300;

vehiclePathPredObj.checkPredict('timePause',timePause,'zoomRatio',zoomRatio, ...
    'mapType',mapType,'updateIter',updateIter,'figurePos',figurePos, ...
    'AutoAxis',AutoAxis,'offset',offset);
%%
DSRC_V2P_11_10.vehicleGT = vehicleData(:,[1 2]);
DSRC_V2P_11_10.vehiclePred = pred_GPS;
DSRC_V2P_11_10.frequency_Hz = 10;
DSRC_V2P_11_10.timeStamp = timestampReshape;
DSRC_V2P_11_10.startTime = t1Reshape(1);
DSRC_V2P_11_10.pedesGT = pedestrianData(:,[1 2]);

%%save('../data/DSRC_V2P_9_29.mat','DSRC_V2P_9_29'); 
save('../data/DSRC_V2P_11_10.mat','DSRC_V2P_11_10');