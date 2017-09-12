% for day1_5Hz_Train training

%day1_10Hz_Train contains 100 trips around ann ardor local region
%the trips are fine(but without filter/smoothing)
%attr = {'VID'1 'TripID'2 'Lat'3 'Long'4 'Elevation'5 'Speed'6 'Heading'7 ...
%    'Ax'8 'Ay'9 'Az'10 'Yawrate'11 'RadiusOfCurve'12 'Confidence'13 'Time'14};
%% setup training network config

% 2 sample delay (2s)
% use 5 samples as input
%load ../model/errMeasurement.mat;
errMeasurement = [];
checkpoint.current = 0;
checkpoint.count = 1;
checkpoint.save = 1;

trainParam.delayindex = 1:3;
trainParam.windowSize = 6:6;
trainParam.hiddenLayer = 10:10;
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

%day1F_train = day1F_train.trainningMode('UTM');
%day1F_train = day1F_train.trainningMode('normal');
[errMeasurement,checkpoint] = day1F_train.trainKFold(trainParam,errMeasurement,checkpoint);

