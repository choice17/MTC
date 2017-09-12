function [TripInfo] = normalizeTripv2(day1sec,Len,option)
%retrieve VID,TripID,Tripstartinfo,normalizeinfo,normalizeTrip
%day1sec [VID TRIPID LAT LONG TIME SPEED]
%option 'Y' normalize gps and velocity value

if nargin<2
    option.operate = 'N';
    option.normalizeSize = 100000;    
end

% read VID
VID = unique(day1sec(:,1),'stable');
% read TripID 
[TripID,index] = unique(day1sec(:,2),'stable');  
TripID = [day1sec(index,1) TripID];

% feature normalize for column 
Fn = [3 4 6];
% total feature have to be standardize
F = 3;


% normalize data 
% crop each trip so that the starting and finishing velocity is 0
% standardize all trip and append the gps to one continuous trip
% store VID TRIPID(w VID) LengthTrip TripStartingPt wholeTrip stdT meanT

% ouput TripInfo
Num = length(TripID(:,2));

% initialize parameter
TripInfo.TripID = TripID;
TripInfo.LengthOfTrip = Len;
TripInfo.CropLen = zeros(size(Len));
TripInfo.StartPoint = zeros(Num,F);
TripInfo.EndPoint = zeros(Num,F);
TripInfo.NormalizeInfo = zeros(1,F*3);
TripInfo.StandardizeTrip = zeros(length(day1sec(:,1)),3);


index = 1;

fprintf('normalizing dataset\n')
for i = 1:Num
    
    oneTripInfo = day1sec((day1sec(:,2)==TripID(i,2)),Fn);
    zVel = find(oneTripInfo(:,3)==0);
    if isempty(zVel)
        %return zVel = 1 and zero trip info
        oneTripInfo = zeros(1,3);
        zVel=1;
    end
    %crop trip for vel from 0 to 0
    oneTripInfo =  oneTripInfo(zVel(1):zVel(end),:);
    cropLen = length(oneTripInfo(:,1));
    %store start and end point
    startPt = oneTripInfo(1,:);
    endPt = oneTripInfo(cropLen,:);
    if i<2
    prevPt = endPt(1,[1 2]);
    end
    %append to previous trip
    if i>1
    locInfo  =oneTripInfo(:,[1 2])-(oneTripInfo(1,[1 2]) - prevPt);
    else 
        locInfo = oneTripInfo(:,[1 2]);
    end
    TripInfo.StandardizeTrip(index:index+cropLen-1,:) = [locInfo oneTripInfo(:,3)];
    
    %save for next trip
    prevPt = locInfo(end,[1 2]);
    index = index+cropLen;
     
    % save information
    TripInfo.CropLen(i) = cropLen;
    TripInfo.StartPoint(i,:) = startPt;
    TripInfo.EndPoint(i,:) = endPt;  
    
    
    printper(i,Num,100);
end
    TripInfo.StandardizeTrip = TripInfo.StandardizeTrip(1:index-1,:);
    TripInfo.CropTrip = TripInfo.StandardizeTrip;
% normalize trip for better training performance
if strcmp(option.operate,'Y')
   %{
    normSize = 1:option.normalizeSize;
    normTrip = TripInfo.CropTrip - TripInfo.CropTrip(1,:);
    meanTrip = mean(normTrip(normSize,:));
    stdTrip = std(normTrip(normSize,:));
    TripInfo.NormalizeInfo = [stdTrip meanTrip normTrip(1,:)];
    TripInfo.StandardizeTrip = (normTrip-meanTrip)./stdTrip;
    %}
    
   
    meanTrip = mean(TripInfo.CropTrip(normSize,:));
    stdTrip = std(TripInfo.CropTrip(normSize,:));
    normTrip = (TripInfo.CropTrip-meanTrip)./stdTrip;
    TripInfo.NormalizeInfo = [stdTrip meanTrip normTrip(1,:)];
    TripInfo.StandardizeTrip = normTrip -normTrip(1,:);  
    
end
    

fprintf('\n Complete!\n')

TripInfo.note = 'NormalizeInfo [std mean normStartPt] is evenly split for features'; 
end

