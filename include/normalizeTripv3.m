function TripInfo = normalizeTripv3(day1sRe)
% TripInfo = normalizeTripv3(day1sRe) 
% %normalize trip with dataset day1sec 
% %A. filter trip which the duration less than fpt(default 8 points)
% %B. extract feature column(default [3 4 6] - [lat long velocity])
% %TripInfo.TripID         : consists all unique tripID
% %TripInfo.LengthOfTrip   : length of each unique tripID
% %TripInfo.StartPoint     : starting point for each trip
% %TripInfo.MeanTrip       : store mean value for each trip
% %TripInfo.NormalizeInfo  : std of the feature 
% %TripInfo.StandardizeTrip: standardize trip - each trip start from zero
% %                                             and overall std=1
% %TripInfo.StandardizeTripCell  : standardize trip in cell format
% %TripInfo.CenteredNormalizeInfo: std of centered feature
% %TripInfo.CenteredTrip         : trip with mean = 0 and std = 1
% %TripInfo.CenteredTripCell     : mean trip = 0 in cell
% %TripInfo.GroundTruth          : origin trip info
%% parameter setup
% feature normalize for column 
Fn = [3:11-1];
% total feature have to be standardize
F = length(Fn);
% filter trip duration <fpt pts
fpt = 1;
% set up polynomial features
p = 0; pf = [3 4 11]; cross = true;
% trip duration order setting 0:no change| 1:ascending
torder = 1;



debugMode = 1;
%%

if p ~=0 
    Fn = min(Fn):(max(Fn)+7);
    F = length(Fn);
end

%% sort the trip in the order of ascending trip duration
day1sRe = sortTripDuration(day1sRe,torder);
% check point        
if debugMode
    TripInfo = day1sRe;
    return
end

%% extract the basic info of the dataset

[TripID,TripIndex] = unique(day1sRe(:,2),'stable');
% Trip length
TripLen = [diff(TripIndex);length(day1sRe(TripIndex(end):end,2))];

% filter index of the dataset 
filterIndex = TripIndex(TripLen>=fpt);
filterLen = TripLen(TripLen>=fpt);
filterID = TripID(TripLen>=fpt);

% TripID :[VID TRIPID]
TripID = [day1sRe(filterIndex,1) day1sRe(filterIndex,3) filterID];

if p~=0
fprintf('adding multi-degree-features...\n');
polycol = polyFeatures(day1sRe(:,[pf]),p,cross);
day1sRe = [day1sRe polycol(:,[4 5 7 8 10 11 12])];
end

% initialize parameter
TripInfo.TripID = TripID;
TripInfo.LengthOfTrip = filterLen;
TripInfo.StartPoint = day1sRe(filterIndex,Fn);
TripInfo.MeanTrip =zeros(size(filterLen,1),F);
TripInfo.STD =zeros(size(filterLen,1),F); % for checking anomal trip
TripInfo.NormalizeInfo = zeros(1,F);
TripInfo.CenteredNormalizeInfo = zeros(1,F);
TripInfo.StandardizeTrip = zeros(sum(filterLen),F);
TripInfo.CenteredTrip = zeros(sum(filterLen),F);
TripInfo.StandardizeTripCell = cell(length(TripInfo.LengthOfTrip),1);
TripInfo.CenteredTripCell = cell(length(TripInfo.LengthOfTrip),1);
TripInfo.GroundTruth = cell(length(TripInfo.LengthOfTrip),1);
clear TripID TripLen TripIndex filterLen;


%% normalization
numTrip = length(TripInfo.LengthOfTrip);
msgl=0;
fprintf('normalizing data...\n');
for i = 1:numTrip
    % index in the data set
    indexData = filterIndex(i):filterIndex(i)+TripInfo.LengthOfTrip(i)-1;
    % index of the TripInfo (output matrix)
    indexTripBegin = (1+(i>1)*sum(TripInfo.LengthOfTrip(1:i-1)));
    indexTrip = indexTripBegin:(indexTripBegin+length(indexData)-1);
    
    % standardize as the zero position
    TripInfo.StandardizeTrip(indexTrip,:) = ...
        day1sRe(indexData,Fn)-TripInfo.StartPoint(i,:);
    TripInfo.MeanTrip(i,:) = mean(day1sRe(indexData,Fn));
    TripInfo.STD(i,:) = std(day1sRe(indexData,Fn));
    
    TripInfo.CenteredTrip(indexTrip,:) = ...
        day1sRe(indexData,Fn)-TripInfo.MeanTrip(i,:);
    TripInfo.GroundTruth{i} = day1sRe(indexData,Fn);
    msgl = printper(i,numTrip,msgl);
    
end

TripInfo.NormalizeInfo = std(TripInfo.StandardizeTrip);
TripInfo.CenteredNormalizeInfo = std(TripInfo.CenteredTrip);

TripInfo.StandardizeTrip = TripInfo.StandardizeTrip./TripInfo.NormalizeInfo;
TripInfo.CenteredTrip = TripInfo.CenteredTrip./TripInfo.CenteredNormalizeInfo;
msgl=0;
fprintf('storing data in cell...\n');
for i = 1:numTrip
    % index in the data set
    indexData = filterIndex(i):filterIndex(i)+TripInfo.LengthOfTrip(i)-1;
    % index of the TripInfo (output matrix)
    indexTripBegin = (1+(i>1)*sum(TripInfo.LengthOfTrip(1:i-1)));
    indexTrip = indexTripBegin:(indexTripBegin+length(indexData)-1);
    
    % standardize as the zero position
    TripInfo.StandardizeTripCell{i} = ...
       num2cell(TripInfo.StandardizeTrip(indexTrip,:)',1);
    TripInfo.CenteredTripCell{i} = ...
       num2cell(TripInfo.CenteredTrip(indexTrip,:)',1);
    TripInfo.LengthOfTrip(i) = length(indexData);
    msgl = printper(i,numTrip,msgl);
end

end
    
function day1sRe = sortTripDuration(day1sRe,torder)
%day1sRe = sortTripDuration(day1sRe,torder);
% %sort trip by trip duration ascending order
% %trip order torder = 0(no change) = 1(ascending)
if nargin==1
    torder =0;
end
%total TripID
if torder == 1
[TripID,~,position] = unique(day1sRe(:,2),'stable');
N = length(TripID);
posindex = [1:length(position)]';
uniqueTrip = [];
msgl=0;

fprintf('checking if there is duplicate tripID...\n');
for i = 1:N
    index = position==i;
    checktrip = find(diff(posindex(index))~=1);
    thistrip = day1sRe(index,:); 
    thistrip2 =[];
    
    if ~isempty(checktrip)
        %check if there is duplicate tripID
        %and rename the duplicate tripID
        fprintf('find one duplicate tripID: %i\n',TripID(i));
        fprintf('rename the duplicate tripID as : %i\n',TripID(i)*1000);
           
        thistrip2 = thistrip(checktrip:end,:);
        thistrip2(:,2) = thistrip2(:,2).*1000;
        thistrip = thistrip(1:checktrip-1,:); 
    end
    
    uniqueTrip = [uniqueTrip;thistrip;thistrip2];
    msgl=printper(i,N,msgl);
end

fprintf('finish checking duplicate ID\n');
%load uniqueTrip.mat
[TripID,tripIDIndex] = unique(uniqueTrip(:,2),'stable');

%trip duration 
tripLen = [diff(tripIDIndex)' length(uniqueTrip(:,1))-tripIDIndex(end)+1];
a = [TripID tripLen']; 
switch torder
    case 1
        [tripLenAscend,tripIndex] = sort(tripLen,'ascend');
        tripDuration = [TripID(tripIndex) tripLenAscend'];
        day1AscTripDuration = zeros(size(uniqueTrip));
        tripAscend = cell(length(tripIndex(1,:)),1);
        j=1;msgl = 0;N = length(tripIndex);
       
        fprintf('start rearranging the trip by ascending trip duration\n');
        for i =1:N
            thistrip = uniqueTrip(uniqueTrip(:,2)==tripDuration(i,1),:);
            
            day1AscTripDuration(j:j+tripDuration(i,2)-1,:)=thistrip;
            tripAscend{i} = thistrip;
            
            j = j + tripDuration(i,2);
            msgl = printper(i ,N,msgl);
        end
end
        day1sRe =[]; 
        
        day1sRe.TripInfo = day1AscTripDuration;
        day1sRe.TripInCell = tripAscend;
        day1sRe.TripID = tripDuration(:,1);
        day1sRe.TripLen = tripDuration(:,2);
end
end




        
        
        
        
        
        
