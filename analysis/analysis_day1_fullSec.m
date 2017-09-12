%% loading the data
%study of 10Hz dataset 
%update 2017-06-16
%created object class day1TripTrain < day1TripAnalysis 
addpath ..\V2P;
addpath ..\include;
addpath ..\analysis;
%% origin dataset
load day1_fullSec.mat;

% the attr of day1_fullSec
% attr of the data
%col   = [ 1 2 3 4 5  6  7  8  9  10 11 12 13 14]
feaCol = [ 1 2 8 9 10 11 12 13 14 15 16 18 19 4 ];
attr = {'VID' 'TripID' 'Lat' 'Long' 'Elevation' 'Speed' 'Heading' ...
    'Ax' 'Ay' 'Az' 'Yawrate' 'RadiusOfCurve' 'Confidence' 'Time'};
% second dataset
day1F = day1_fullSec(:,feaCol);
%% Analysis the dataset
% day1F_Re is dataset rearrange the length using normalizationTripV3.m
%total VID
day1F = day1F_Re.TripInfo;
VID = unique(day1F(:,1),'stable');
numVID = length(VID);

%total TripID
[TripID,tripIDIndex] = unique(day1F(:,2),'stable');
numTripID = length(TripID);
ID = day1F(tripIDIndex,[1 2]);
%check total data point per trip
%tripLen = [diff(tripIDIndex)' length(day1F(:,1))-tripIDIndex(end)];
%min(tripLen) is 60
tripLen = day1F_Re.TripLen;
%% ERROR checking
%re-arrange trip to ascending order of trip duration
%day1F = triparrange(day1F);

%check extreme data point err
%lat: (max(day1F(:,3)) : 90 , Long: (max(day1F(:,4)) :180
%max of elevation max(day1F(:,5)) % = 6.5535e+03;
%no negative err

%filter extreme case (gps error and elevation error)
%find err index 
%gps and elevation
errTrip = unique(day1F( (day1F(:,3)>48.5 | day1F(:,3)<25 | ...
    day1F(:,4)>-60 | day1F(:,4)<-120 | day1F(:,5)>1000 | abs(day1F(:,11)>180) ),2),'stable');
%gps error
errTrip = unique(day1F( (day1F(:,3)>48.5 | day1F(:,3)<25 | ...
    day1F(:,4)>-60 | day1F(:,4)<-120),2),'stable');
%elevation error
errTrip = unique(day1F(  day1F(:,5)>1000,2),'stable');

%gps error look for sparse gps

errTrip = unique(day1F( (day1F(:,3)>42.04 & day1F(:,3)<42.14 & ...
    day1F(:,4)>-83.49 & day1F(:,4)<-83.4),2),'stable');

errTrip = unique(day1F( (day1F(:,10)==-10),2),'stable');


%% Inspect error

inspectTripAttr(day1F_Re,'TripID',1959043)

%% manually inspect each trip gps and attribute to extract 
%  no obvious error trip

for i = 3845:-1:3600
    close all;
%inspectTripAttr(day1F_Re,'TripIndex',i)
[~,b,c] = day1F_Obj.inspectTrip('TripIndex',i,[],1,[]);

pause();
end




%% error checking
totalerrData = sum(day1F(:,3)==90 | day1F(:,4)==180 | ...
    day1F(:,5)>1000 );


%% check error Trip
errorSummary = cell(length(errTrip),4);
k=1;
for i = 1:5897
    for j = 1:length(errTrip)
    if day1F_Re.TripID(i) == errTrip(j)
    thistrip = day1F_Re.TripInCell{i};
    errorData =  find(thistrip(:,3)>48.5 | thistrip(:,3)<25 | ...
    thistrip(:,4)>-60 | thistrip(:,4)<-120);
    errorSummary{k,1} = errTrip(j);
    errorSummary{k,2} = errorData;
    errorSummary{k,3} = length(errorData);
     errorSummary{k,4} = day1F_Re.TripLen(i);
    k = k+1;
    end
    end
end

%get the good trip number
goodID = sum((TripID~=errTrip'),2);
goodID = TripID(goodID==length(errTrip));

%filter trip here
day1fRe=zeros(size(day1F));
n=1;
L=zeros(size(goodID));
msgl=0;
for i=1:length(goodID)
    trip = day1F(day1F(:,2)==goodID(i),:);
    si = size(trip,1);
    %filter trip less 30s
    if si>=10*30
    day1fRe(n:n+si-1,:) = trip;
    n = n + si;
    L(i) = si;
    else 
        L(i) = 0;
    end    
    msgl = printper(i,length(goodID),msgl);
end

day1fRe = day1fRe(1:n-1,:);
LengthofTrip = L(L~=0);

% Check if there is trip without moving 
day1fRe_std = zeros(length(LengthofTrip),2);
mgl=0;
for i=1:length(LengthofTrip)
    day1fRe_std(i,:) = std(day1fRe(1:LengthofTrip(i)-1,[3 4]));    
    msgl = printper(i,length(goodID),msgl);
end

%save V2P\day1fRe.mat LengthofTrip day1fRe;
%% normalize dataset
% to change the input file
%TripInfo = normalizeTripv3(day1_fullSec);
TripInfo = normalizeTripv3(day1F);

%TripInfo1FHzP = TripInfo;
%{
temp.ID = TripInfo.TripID;
temp.LengthOfTrip = TripInfo.LengthOfTrip;
%temp.StartPoint = TripInfo.StartPoint;
temp.MeanTrip = TripInfo.MeanTrip;
%temp.NormalizeInfo = TripInfo.NormalizeInfo;
temp.CenteredNormalizeInfo = TripInfo.CenteredNormalizeInfo;
%temp.StandardizeTripCell = TripInfo.StandardizeTripCell;
temp.CenteredTripCell = TripInfo.CenteredTripCell;
temp.TripAttribute = TripInfo.GroundTruth;
TripInfo1FHzP = temp;
%}

%save V2P/TripInfo1FHzP TripInfo1FHzP

%% plot all the trip using plottrip
figure(2);
%plot(0,0);
%set(gca,'Color',[0 0 0]);
%hold on;

%testtrip = day1F_train.TripInfo(:,[1 2 4 3 6 14 ]);
testtrip = day1F_train.TripInCell{74}(:,[1 2 4 3 6 14 ]);
plottrip(testtrip,0.1,'Y');

%plot(testtrip(:,4),testtrip(:,3),'.')
%% 2017-06-16 data summary trip distance
% day1F_train object
tripDis = zeros(100,1);
tripPlot = cell(100,1); 
f1 = figure(1);
for i = 1:100
[tripDis(i),tripPlot{i}] = day1F_train.getTripDist('TripIndex',i);
[tripDis(i),tripPlot{i}] = day1_2Hz_Train.getTripDist('TripIndex',i);
end

% trip mean speed
meanSpeed = zeros(100,1);
speed2DistRatio = zeros(100,1);
for i = 1:100
meanSpeed(i) = mean(day1F_train.TripInCell{i}(:,6));

end

% tripaddr
tripAddr = cell(100,1);
for i = 35:38
tripAddr{i} = day1F_train.getTripAddr('TripIndex',i);
end

% tripSumYawrate
tripSumYawrate = zeros(100,1);
for i = 1:100
tripSumYawrate(i) = sum(abs(day1F_train.TripInCell{i}(:,[11])))/tripDis(i);

end


%% inspect trip
%tripInfo = cell(100,2);
% inspect trip
%tripIndex

for i = 4442:5000
    f1 = figure(1);
    i
[~,tripInfo{i,2},tripInfo{i,1}] = day1F_Obj.inspectTrip('TripIndex',i,[],1,[]);
pause();
 clear('f1');
 close;
end
%% remove trip by ID
option.Index = 'TripIndex';
option.Operation = 'keep';
tripIndex = 3400:4442;
day1F_train = day1F_train.removeTripByID(option,tripIndex);
%% find trip by attr
option.maxSpeed = 21;
option.indexRange = 1:122;
option.dist = [5 12];
option.addr = 'AnnArbor';
[tripIndex,~,tripInfo] = day1F_train.findTripWithAttr(option);
tripID  = day1F_train.TripID(1:100);

%% trip complexity
Acc = zeros(100,1);
Yaw = zeros(100,1);
for i = 1:100

[Acc(i), Yaw(i)] = day1F_train.getTripDifficulty('TripIndex',i);

end
%% Az study
thisTrip = day1F_train.TripInCell{38}(:,[3 4 12]);

    
plot(thisTrip(:,2),thisTrip(:,1),'r.');

for i = 1:day1F_train.TripLen(38)
    text(thisTrip(i,2),thisTrip(i,1),[num2str(i,'%i') ' ROC ' num2str(floor(thisTrip(i,3)),'%i')],'Color','black','FontSize',8);
end

plot_google_map;

%% 
plot(day1F_train.TripInCell{38}(:,10)); xlabel('time stamp (s)');
ylabel('Az (m^2/s)');title('FileID 1973007')
%% Az study
% check +ve number of Az
a = find(day1_fullSec(:,15)>0);
tripID = unique(day1_fullSec(a,2));
%%
for i = 36:38
thistrip = day1F_train.inspectTrip('TripIndex',i,[],1,[]);
%plot(thistrip(:,15))
pause();
close all;
end 
%% Ax study
thisLat =day1F_train.TripInCell{38}(:,4);
subplot 411;
plot(thisLat);
d1 = conv(thisLat,[1 -1],'valid').*111320;
subplot 412;
plot(d1);
d2 = conv(thisLat,[1 -2 1],'valid').*111320;
subplot 413;
plot([d2]); hold on;
plot(day1F_train.TripInCell{38}(:,9));
hold off;
subplot 414;
plot(day1F_train.TripInCell{38}(:,9));
%% error plot
load ..\model\net-GPS-model1to3sec\errMeasurement.mat
ModelError1to3sec = errMeasurement(1:162,:);
load ..\model\net-GPS-model3to5sec\errMeasurement.mat
ModelError3to5sec = errMeasurement;

errMeasurement1to5 = [ModelError1to3sec;ModelError3to5sec];

errPlot = getMatErrorMeasurement(errMeasurement1to5);

%for 1sec
ModelError{1} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==1,:);
ModelError{2} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==2,:);
ModelError{3} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==3,:);
ModelError{4} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==4,:);
ModelError{5} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==5,:);

numModel =length(ModelError(:,1));

%% for 1sec
marker = {'o','+','*','x','s','d','p','h','s'};
for i = 1:5
   figure(i);
for windowSize = 2:10
        
        color = rand(1,3);
        hiddenSize = 2:10;
        index = ModelError{i}(:,2)==windowSize;
        modelPlot = plot(hiddenSize,ModelError{i}(index,5), ...
            [marker{windowSize-1} '--'],'MarkerSize',5, ...
            'MarkerFaceColor',color,'LineWidth',0.5,'Color',color);
        [i windowSize find(ModelError{i}(index,5) == min(ModelError{i}(index,5))) min(ModelError{i}(index,5))]
        hold on;  
        
end


title(['Predict ' num2str(i)  's Neural network hidden neuron size to error (m)']);
xlabel('hidden layer size');
ylabel('K-fold error(m)');
hleg = legend('2s','3s','4s','5s','6s','7s','8s','9s','10s');
htitle = get(hleg,'Title');
set(htitle,'String','window size')
hold off;
end

%% error plot 2017-7-09
load ..\model\net-GPS-model1to3sec5to6RS\errMeasurement.mat
ModelError1to3sec = errMeasurement(204:end,:);
load ..\model\net-GPS-model1to3sec2to4RSandOther\errMeasurement.mat
ModelError3to5sec = errMeasurement;

errMeasurement1to5 = [ModelError1to3sec;ModelError3to5sec];

errPlot = getMatErrorMeasurement(errMeasurement1to5);


%for 1sec
ModelError{1} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==1,:);
ModelError{2} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==2,:);
ModelError{3} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==3,:);
ModelError{4} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==4,:);
ModelError{5} = errPlot.modelParameterErr(errPlot.modelParameterErr(:,1)==5,:);

numModel =length(ModelError(:,1));
%%
close all;
marker = {'o','s','p','h','+','*','p','h','s'};
colorR = rand(5,3);
for i = 1:5
   figure(i);
for windowSize = 2:6
        
        %color = RGB(windowSize-1,:);
        hiddenSize = 2:10;
        randomSeed = 5;
        index = ModelError{i}(:,2)==windowSize;
        ploterror = min(reshape(ModelError{i}(index,5),randomSeed,[]));
        modelPlot = plot(hiddenSize,ploterror, ...
            [marker{windowSize-1} '--'],'MarkerSize',5, ...
            'MarkerFaceColor',color,'LineWidth',1)%'Color',color);
        %[i windowSize find(ModelError{i}(index,5) == min(ModelError{i}(index,5))) min(ModelError{i}(index,5))]
        hold on;  
        
end


title(['Predict ' num2str(i)  's Neural network hidden neuron size to error (m)']);
xlabel('hidden layer size');
ylabel('K-fold error(m)');
hleg = legend('2s','3s','4s','5s','6s','7s','8s','9s','10s');
htitle = get(hleg,'Title');
set(htitle,'String','window size')
hold off;
end
        
    
    
%%
[A,index] = sort(errPlot.modelParameterErr(:,2));
terrPlot.modelParameterErr = errPlot.modelParameterErr(index,:)
[A,index] = sort(terrPlot.modelParameterErr(:,1));
terrPlot.modelParameterErr = terrPlot.modelParameterErr(index,:)
%%

close all;
marker = {'o','s','p','h','+','*','p','h','s'};
colorR = rand(5,3);
figure(6);
for i = 1:5   
    windowSize = 2:6;
        
        
        hiddenSize = 5;
        randomSeed = 5;
        index = ModelError{i}(:,3)==hiddenSize;
        ploterror = min(reshape(ModelError{i}(index,5),randomSeed,[]));
        modelPlot = plot(windowSize,ploterror, ...
            [marker{i} '--'],'MarkerSize',5, ...
            'LineWidth',1);%'Color',color);
         set(modelPlot, 'MarkerFaceColor', get(modelPlot, 'Color'));
        %[i windowSize find(ModelError{i}(index,5) == min(ModelError{i}(index,5))) min(ModelError{i}(index,5))]
        hold on;  
        
end


title(['Predict t+n (s) Neural network to error (m)']);
xlabel('Window size (s)');
ylabel('K-fold error(m)');
hleg = legend('1s','2s','3s','4s','5s');
htitle = get(hleg,'Title');
set(htitle,'String','predict t+n (s)')

        
    