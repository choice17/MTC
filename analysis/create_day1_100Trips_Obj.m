% ISL MTC data analysis script
% data: UTMTRI data, collection1 2016/6 day one data
% Create, analysis, filter and resample raw file day1_full.mat
% please refer to day1TripTrain() for more details of object functionality
% step1. load the raw data.
% step2. construct day1TripTrain Object for later study
% step3. quick look into dataset and noise
% step4. filter and extract 100 trips for study
% step5. resample the data to different frequency
% created @ 10/7/2017 - tcyu@umich.edu 

%% add path
clear; clc;
addpath ../analysis
addpath ../include
addpath ../include/day1TripObj
addpath ../include/VehicleFutPathPred
addpath ../include/utility

%% step1. load the raw data.
% please download the raw file from ISL cloud data repository
% under folder MTC collection1
load ../data/day1_full.mat % 49497012x19 double

%% step2. construct day1TripTrain Object for later study

% step2-1 create an empty object
day1_obj = day1TripTrain();

% step2-2 put the data in the in cell and rename duplicate trip ID 
msg = input('Warning: This would take 1 to 2 hours, continue... ? [Yes]/[No]:','s');
switch msg
    case 'Yes'
        day1_fullRe = day1_obj.putDataInCell(day1_full); 

        % step2-3 create a day1TripTrain obj
        day1_full_obj = day1TripTrain(day1_fullRe);
    case 'No'
end

%% step3. quick look into dataset and noise

% step3-1 find noise trip data by elevation
errTrip = unique(day1_full_obj.TripInfo(day1_full_obj.TripInfo(:,5)>1000,2),'stable');

% step3-2 display trip data info
day1_full_obj.inspectTrip('TripID',errTrip(1));
pause();
% step3-1 find noise trip data by elevation and gps dis allocation
errTrip = unique(day1_full_obj.TripInfo( ...
    (day1_full_obj.TripInfo(:,3)>48.5 | day1_full_obj.TripInfo(:,3)<25 | ...
    day1_full_obj.TripInfo(:,4)>-60 | day1_full_obj.TripInfo(:,4)<-120 | ...
    day1_full_obj.TripInfo(:,5)>1000 | abs(day1_full_obj.TripInfo(:,11)>180)), ...
    2),'stable');

% step3-2 display trip data info
day1_full_obj.inspectTrip('TripID',errTrip(1));
pause();
%% step4. filter and extract 100 trips for study

% step4-1 setup and filter trips by trip len
% remove trip by trip length (trip index is aligned with trip length)
% 3400 ~ 4442 is around 10 to 15 mins (for short trips)
option.Index = 'TripIndex';
option.Operation = 'keep';
tripIndex = 3400:4442;
day1_filt_obj = day1_full_obj.removeTripByID(option,tripIndex);
pause();

% step4-2 find trip by option, local(speed/dist travel)
option.maxSpeed = 21;
option.indexRange = 1:length(day1_filt_obj.TripLen);
option.dist = [5 12];
option.addr = [];
[tripIndex,problemFlag,tripInfo] = day1_filt_obj.findTripWithAttr(option);
day1_filt_obj = day1_filt_obj.removeTripByID(option,tripIndex);
pause();

% step4-3 find trip by address (note. addr flag enable google api which is
% limited resource so only use it at shortlisted trips)
option.addr = 'AnnArbor';
option.indexRange = 1:length(day1_filt_obj.TripLen);
[tripIndex,problemFlag,tripInfo] = day1_filt_obj.findTripWithAttr(option);
day1_100_obj = day1_filt_obj.removeTripByID(option,tripIndex(1:100));

% disp the filter trips
% 100 trips
% speed < 21 m/s
% trip lens [10,15] mins
% dist travelled [5,12] km
% location: Ann Arbor
day1_100_obj.inspectTrip('TripIndex',1,'addressOn',1)
%% save temp file 
save ../data/day1_100_obj.mat day1_100_obj
%load ../data/day1_100_obj.mat
%% step5. resample the data to different frequency
fprintf('The dataset is now %d Hz\n',day1_100_obj.getDataFreq());

%re-sample and filtering on 10Hz
option.sampleRate = 1;
option.algorithm = 'moving';
option.windowSize = 11;
day1_10Hz_Train = day1_100_obj.downSample(option);
fprintf('The dataset day1_10Hz_Train is now %d Hz\n',day1_10Hz_Train.getDataFreq());

%downsample to 5Hz
option.sampleRate = 0.5;
option.algorithm = 'moving';
option.windowSize = 11;
day1_5Hz_Train = day1_100_obj.downSample(option);
fprintf('The dataset day1_5Hz_Train is now %d Hz\n',day1_5Hz_Train.getDataFreq());

%downsample to 2Hz
option.sampleRate = 0.2;
option.algorithm = 'moving';
option.windowSize = 11;
day1_2Hz_Train = day1_100_obj.downSample(option);
fprintf('The dataset day1_2Hz_Train is now %d Hz\n',day1_2Hz_Train.getDataFreq());

%downsample to 1Hz
option.sampleRate = 0.1;
option.algorithm = 'moving';
option.windowSize = 11;
day1_1Hz_Train = day1_100_obj.downSample(option);
fprintf('The dataset day1_1Hz_Train is now %d Hz\n',day1_1Hz_Train.getDataFreq());


% uncomment to save the resampled object
%save ../data/day1_2Hz_Train.mat day1_2Hz_Train
%save ../data/day1_5Hz_Train.mat day1_5Hz_Train
%save ../data/day1_1Hz_Train.mat day1_1Hz_Train
%save ../data/day1_10Hz_Train.mat day1_10Hz_Train




