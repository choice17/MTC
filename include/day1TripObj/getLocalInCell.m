function  obj = getLocalInCell(trip_obj,gpsMode)
% Objective: to initialize/normalize dataset for training purpose
% input: trip_obj , please refer to create_day1_100Trips_Obj.m to see
% initialization
%        gpsMode, 'UTM' - support UTM mode, tranform GPS degree to UTM
%                         format, and store in cell
% output:  localInCell, normalized trips in cell format
%          tripStart,   store the trip beginning GPS location
%          gpsSTD,      in GPS mode 'normal', it will normalize the normal by
%                       std normalization
% %          tripZone,    store trip Zone, only valid in GPS mode 'UTM'
%          tripInfo,    big matrix 

if nargin == 1 
    gpsMode = 'normal';
    tripStart = [];
    tripZone = [];
    
end

%local speed
speedSTD  = 20;
elevationMean = 230;
elevationSTD = 20;
yawNorm = 20;
ROCNorm = 3000;
%gpsLocal =  [42.3053253 -83.6694169]; % ann arbor
gpsLocal = []; 

numTrip  = length(trip_obj.TripID);
localInCell = cell(numTrip,1);
if strcmp(gpsMode,'UTM')
    tripStart = zeros(numTrip,2);
    %gpsSTD = [1058 1227];
    %disp('debug value on gpsSTD');
    warning('default window size is 3s in segment normalization')
    gpsSTD = speedSTD*3;
    %gpsSTD  = 1;
    tripZone = cell(numTrip,1);
elseif strcmp(gpsMode,'normal')
    tripStart = [];
    %paramter here approximation for ann arbor region
    gpsSTD = [0.1 0.14];  %0.1 is city level/0.01 is town level
end
    
tripInfo = [];





for i = 1:numTrip
    thisTrip = trip_obj.TripInCell{i};
    %thisTrip ID
    thisTripID = thisTrip(:,[1 2]);
    %To normalize gps value
    if isempty(gpsLocal)
        if strcmp(gpsMode,'normal')
            thisTripGPS = bsxfun(@times,bsxfun(@minus,thisTrip(:,[3 4]),trip_obj.Start(i,:)),1./gpsSTD);
        elseif strcmp(gpsMode,'UTM')
            [thisTripx,thisTripy,tripZone{i}]=ll2utm(trip_obj.TripInCell{i}(:,[3 4]));
            thisTripGPS = [thisTripy thisTripx];
            tripStart(i,:) = thisTripGPS(1,:);
            thisTripGPS = bsxfun(@times,bsxfun(@minus,thisTripGPS,tripStart(i,:)),1./gpsSTD);
            %thisTripGPS = bsxfun(@minus,thisTripGPS,tripStart(i,:));
            
        end
    
    
    else
      thisTripGPS = bsxfun(@times,thisTrip(:,[3 4]),1./gpsSTD);
    end
    %To normalize speed ~[0 20] (m/s) (local road) std~10
    thisTripSpeed = thisTrip(:,[6])./speedSTD;
    %To normalize elevation ~mean 230 (m)  std~20
    thisTripElevation = (thisTrip(:,[5])-elevationMean)./elevationSTD;
    
    %To normalize heading 
    thisTripHeading = thisTrip(:,[7]);
    smoothOption.smoothAlg = 'moving' ;
    smoothOption.windowSize = 5;
    thisTripHeading = degSmooth(thisTripHeading,smoothOption);
    thisTripHeading = deg2rad(thisTripHeading)-pi;
    %thisTripHeading = cos(deg2rad(thisTrip(:,[7])));
    %thisTripNorHeading = [cos(deg2rad(thisTrip(:,[7]))) ...
    %    sin(deg2rad(thisTrip(:,[7])))]; 
   
    %To normalize Ax lat acceleration
    thisTripAx = thisTrip(:,[8]);
    %To normalize Ay lng acceleration
    thisTripAy = thisTrip(:,[9]);
    %To normalize Az elevation acceleration
    thisTripAz = thisTrip(:,[10]);
    %To normalize Yawrate
    thisTripYawrate = thisTrip(:,[11])./yawNorm;
    %To normalize ROC radius of curve need to work on it    
    thisTripROC = thisTrip(:,[12])./ROCNorm;
    %thisTripROC(abs(thisTripROC)>100&abs(thisTripROC)<=500)=100;
    %
    %  thisTripROC((thisTripROC<1) & (thisTripROC>0),:)=1;
    %thisTripROC((thisTripROC<0) & (thisTripROC>-1))=-1;
    %thisTripROC(thisTripROC==0) = 5000;
    %if (sum(thisTripROC==0) +  sum(abs(thisTripROC)<1))>0
    %    warning(['trip index' num2str(i) 'ROC value is abnormal']);
    %end
        
    %thisTripROC = 10./thisTripROC;
    
    %To normalize confidence (percentage)
    thisTripConfidence = thisTrip(:,[13])./100;
    %time
    thisTripTime = thisTrip(:,[14]);
    
    localInCell{i} = [ thisTripID, thisTripGPS, thisTripElevation, ...
        thisTripSpeed, thisTripHeading, ...
        thisTripAx, thisTripAy, thisTripAz, thisTripYawrate, ...
        thisTripROC, thisTripConfidence, thisTripTime];
    obj = trip_obj;
    obj.LocalTripCell = localInCell;
    if strcmp(gpsMode,'UTM')
        obj.Start = tripStart;
        obj.TripZone = tripZone;
    end
    obj.TripSTD = gpsSTD;    
    obj.TripZone = tripZone;
    obj.TripInfo = tripInfo;
    normInfo.gpsNorm = gpsSTD;
    normInfo.speedSTD  = speedSTD;
    normInfo.elevationMean = elevationMean;
    normInfo.elevationSTD = elevationSTD;
    normInfo.yawNorm = yawNorm;
    normInfo.ROCNorm = ROCNorm;
    obj.NormInfo = normInfo;
end
    

end