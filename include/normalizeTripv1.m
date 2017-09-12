function [VID,TripInfo] = normalizeTripv1(day1sec)
%retrieve VID,TripID,Tripstartinfo,normalizeinfo,normalizeTrip
%day1sec [VID TRIPID LAT LONG TIME SPEED]
%delete TripId :deleteTripID
%filter which tripID has only one data

% read VID
VID = unique(day1sec(:,1),'stable');
% read TripID 
TripID = unique(day1sec(:,2),'stable');  


% feature normalize for column 
Fn = 3:6;
% total feature have to be standardize
F = 3;


% ouput TripInfo
Num = length(TripID);

% initialize parameter
TripInfo.TripID = zeros(Num,1);
TripInfo.LengthOfTrip = zeros(Num,1);
TripInfo.StartPoint = zeros(Num,4);
TripInfo.NormalizeInfo = zeros(Num,F*2);
TripInfo.StandardizeTrip = zeros(length(day1sec(:,1)),4);


index = 1;

fprintf('normalizing dataset\n')
for i = 1:Num
    
    lenTrip = length(day1sec((day1sec(:,2)==TripID(i)),2));
    oneTripInfo = day1sec((day1sec(:,2)==TripID(i)),Fn);
    startPt = oneTripInfo(1,:);
    [stdT,meanT,normT] = standardizeTrip(oneTripInfo);
    normalizeInfo = [stdT,meanT];    
  
    % save information
    TripInfo.TripID(i) = TripID(i);
    TripInfo.LengthOfTrip(i) = lenTrip;
    TripInfo.StartPoint(i,:) = startPt;
    TripInfo.NormalizeInfo(i,:) = normalizeInfo;
   
    TripInfo.StandardizeTrip(index:index+lenTrip-1,:) = normT;
    index = index + lenTrip;
    if mod(i,ceil(Num/100))==0
        fprintf('\t%d percent\t\n',i/ceil(Num/100));
    end
end
fprintf('/n Complete!/n')

TripInfo.note = 'NormalizeInfo [std mean] is evenly split for features'; 


