classdef day1TripAnalysis
    properties
    TripID
    TripInfo
    TripInCell
    TripLen
    TripAttr
    Log 
    end
    
    methods
        function obj = day1TripAnalysis(day1F_Re)
            
            if nargin == 1
                if isa(day1F_Re,'cell')
                    obj.TripAttr = {'VID' 'TripID' 'Lat' 'Long' 'Elevation' ...
                            'Speed' 'Heading' 'Ax' 'Ay' 'Az' 'Yawrate' ... 
                            'RadiusOfCurve' 'Confidence' 'Time'};
                    obj.TripID = unique(cellfun(@(x) unique(x(:,2)),day1F_Re),'stable');
                    obj.TripInCell = day1F_Re;
                    obj.TripLen = cellfun(@(x) size(x,1),day1F_Re)';
                    sampleRate =  10/round(mean(diff(day1F_Re{1}(:,end)))/1E5);
                    obj.Log = {[num2str(sampleRate)...
                        ' Hz data Arranged the trip in ascending trip duration, ', ...
                        'created at ' datestr(now)]};
                    
                
                else
                    try 
                        obj.TripAttr = day1F_Re.TripAttr;
                    catch                
                        obj.TripAttr = {'VID' 'TripID' 'Lat' 'Long' 'Elevation' ...
                            'Speed' 'Heading' 'Ax' 'Ay' 'Az' 'Yawrate' ... 
                            'RadiusOfCurve' 'Confidence' 'Time'};
                    end
                    obj.TripID = day1F_Re.TripID;
                    obj.TripInfo = day1F_Re.TripInfo;
                    obj.TripInCell = day1F_Re.TripInCell;
                    obj.TripLen = day1F_Re.TripLen;

                    obj.Log = {['Arranged the trip in ascending trip duration, ', ...
                        'created at ' datestr(now)]};
                end
            end
            if nargin == 0
                obj.TripAttr = [];
                obj.TripID = [];
                obj.TripInfo = [];
                obj.TripInCell = [];
                obj.TripLen = [];
            end
        end
        
        function day1F_Re = putDataInCell(obj,day1_fullSec,attr)
            if nargin == 2
                attr = [];
            end
            day1F_Re = goPutDataInCell(day1_fullSec,attr);
            
        end
        
        function obj = rearrangeTrip(obj,option)
        %obj = rearrangeTrip(obj,option)
        %rearrange trip obj by trip Len with option "ascend"/"descend"
        %only affect on .TripID/.TripLeb/.TripInCell
        if nargin == 1
            option = 'ascend';
        end
        
        [tripLen,tripIdx] = sort(obj.TripLen,option);
                
        obj.TripInCell = obj.TripInCell(tripIdx);
        obj.TripLen = tripLen;
        obj.TripID = obj.TripID(tripIdx);
        
        obj.Log = [obj.Log; ...
            {['Arranged the trip in' option 'ing trip duration, ', ...
                        'at ' datestr(now)]}];
        
        end
                
            
        
        
        
        
        
        function obj = removeTripByID(obj,option,ID)
        %obj = removeTripByID(obj,option,ID)    
        %option.Index: 'TripID'/'TripIndex'
        %option.Operation: 'delete','keep'
        %                  if 'keep' : remove all trips except ID listed
        %                  if 'delete': remove listed ID
        % ID should be either TripID or row index in the array
        % should be N by 1 vector
        
        %working on it
        if strcmp(option.Index,'TripID')
            index = find(sum(obj.TripID==(ID'),2));
        elseif strcmp(option.Index,'TripIndex')
        index = ID;
        else 
            fprintf('not valid option\n');
        end
        
        obj = goRemoveTrip(obj,option.Operation,index);
                
        end       
        

        
        function [index,gpsAddress,meanspeed]  = inspectTrip(obj,option,ID,varargin)
        % index = inspectTrip(option,ID,dataNum,addressOn,maptype)
        % to plot the information of the attribute and map for inspection
        % input:    option: 'TripID'/'TripIndex' 
        %           ID: either index of the trip in day1F_Re or tripID number
        %           obj rearranged the trip day1_fullSec
        %           dataNum: integer so that to inspect specific point in map
        %           addressOn: to show the address of the trip
        %           mapType: gooMaptype
        
        
        
        day1F_Re = obj;    
        [index,gpsAddress,meanspeed] = inspectTripAttr(day1F_Re,option,ID,varargin);
       
    end
    end
end

function obj = goRemoveTrip(obj,operation,index)

tripObj = obj;
if strcmp(operation,'keep')
    %retrieve one trip
    TripID = tripObj.TripID(index);
    TripLen = tripObj.TripLen(index);
    TripAttr = tripObj.TripAttr;
    Log = tripObj.Log;
    numTrip = length(index);
    TripInCell = cell(numTrip,1);
    TripInfo = zeros(sum(TripLen),size(tripObj.TripInfo,2));
    
    tripIndex = 1;
    for i = 1:numTrip
       tripInfoIndex = tripIndex:tripIndex+TripLen(i)-1;
       TripInCell{i} =  tripObj.TripInCell{index(i)};
       TripInfo(tripInfoIndex,:) = tripObj.TripInCell{index(i)};
       tripIndex = tripIndex+TripLen(i);
    end
       
    Log = [Log; ['keep only ' num2str(numTrip,'%i') ' trips. Done at ' datestr(now)]];    
    obj.TripID =  TripID;
    obj.TripInfo = TripInfo;
    obj.TripInCell = TripInCell;
    obj.TripLen = TripLen;
    obj.TripAttr = TripAttr;
    obj.Log = Log;
    
elseif strcmp(operation,'delete')
    % not done yet

end


end

function  day1F_Re = goPutDataInCell(day1_fullSec,attr)
%day1sRe = sortTripDuration(day1sRe,torder);
% %sort trip by trip duration ascending order
if nargin == 1 || isempty(attr)
attr.featCol = [ 1 2 8 9 10 11 12 13 14 15 16 18 19 4 ];
attr.Name = {'VID' 'TripID' 'Lat' 'Long' 'Elevation' ...
        'Speed' 'Heading' 'Ax' 'Ay' 'Az' 'Yawrate' ... 
        'RadiusOfCurve' 'Confidence' 'Time'};
elseif length(attr.featCol) ~= length(attr.featCol)
    error('attr name and number feature column are not balanced');
end
    


%total TripID
[TripID,~,position] = unique(day1_fullSec(:,2),'stable');
N = length(TripID);
posindex = [1:length(position)]';
uniqueTrip = [];
msgl=0;

fprintf('checking if there is duplicate tripID...\n');
for i = 1:N
    index = position==i;
    checktrip = find(diff(posindex(index))~=1);
    thistrip = day1_fullSec(index,:); 
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
 
%sort the trip in ascending order
featLen = length(attr.featCol);
[tripLenAscend,tripIndex] = sort(tripLen,'ascend');
tripDuration = [TripID(tripIndex) tripLenAscend'];
day1AscTripDuration = zeros(length(uniqueTrip(:,1)),featLen);
tripAscend = cell(length(tripIndex(1,:)),1);
j=1;msgl = 0;N = length(tripIndex);

fprintf('start rearranging the trip by ascending trip duration\n');
for i =1:N
    thistrip = uniqueTrip(uniqueTrip(:,2)==tripDuration(i,1),attr.featCol);

    day1AscTripDuration(j:j+tripDuration(i,2)-1,:)=thistrip;
    tripAscend{i} = thistrip;

    j = j + tripDuration(i,2);
    msgl = printper(i ,N,msgl);
end

day1F_Re =[]; 

day1F_Re.TripInfo = day1AscTripDuration;
day1F_Re.TripInCell = tripAscend;
day1F_Re.TripID = tripDuration(:,1);
day1F_Re.TripLen = tripDuration(:,2);
day1F_Re.TripAttr = attr.Name;
end











