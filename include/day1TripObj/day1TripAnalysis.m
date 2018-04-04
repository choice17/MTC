classdef day1TripAnalysis
    % day1TripAnalysis
    % Object: mainly deal with data manipulation 
    %         - time series training section
    %         - segment feature extraction for x-y coord time series data in
    %         feed forward neural network training
    % Properties:
    %         TripID         - store Trip ID
    %         TripInfo       - store raw data in big matrix
    %         TripInCell     - store raw data in Cell format w.r.t. TripID
    %         TripLen        - store Trip length (time stamp) w.r.t. cell
    %                          index
    %         TripAttr       - description of the trip attributes
    %         Log            - log the operation on the dataset
    % Methods:
    %         day1TripAnalysis()
    %         putDataInCell()
    %         rearrangeTrip()
    %         removeTripByID()
    %         inspectTrip()
    %         addTripInfo()
    %         getDataFreq()
    %         getHeading()
    %         getTripDist()
    %         distance2Point()
    %         findTripWithAttr()
    %         downSample()
    
    properties (Access = public)
    TripID
    TripInfo
    TripInCell
    TripLen
    TripAttr
    Log 
    end
    
    methods
        function obj = day1TripAnalysis(day1F_Re)
            
            if nargin == 0 || isempty(day1F_Re)
                obj.TripAttr = [];
                obj.TripID = [];
                obj.TripInfo = [];
                obj.TripInCell = [];
                obj.TripLen = [];
                
                
            elseif nargin == 1
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
                
        function obj = addTripInfo(obj,attrName,data)
            % obj = addTripInfo(obj,attrName,data)
            % add attribute and data into TripInfo
            obj.TripInfo = [obj.TripInfo array2table(data,... 
                'VariableNames',{attrName})];
            
            obj.Log = [obj.Log;['adding ' attrName ' to TripInfo. Created at ' ...
                datestr(now)]];            
        end    
        
        function heading = getHeading(obj,option,ID)
            if strcmp(option,'TripIndex')
                heading = obj.TripInCell{ID}(:,7);
            end
        end
        
        function addr = getTripAddr(obj,option,ID)
            if strcmp(option,'TripID')
                index = find(sum(obj.TripID==(ID'),2));
            elseif strcmp(option,'TripIndex')
                index = ID;
            else 
                fprintf('not valid option\n');
            end
            
            gpsPoint = obj.TripInCell{index}(1,[3 4]);
            
            addr = getAddressByGPS(gpsPoint);
        end
        
        function freq = getDataFreq(obj)
        % to get the frequency of dataset by assess the time interval
            dataTS = 100000; % time units in us
            freq = round(1/(mean(diff(obj.TripInCell{1}(:,end)))/(10*dataTS)));
        end
        
        function dist = distance2Point(obj,in_x1,in_y1,in_x2,in_y2)
        deltaX = in_x2-in_x1;
        deltaY = in_y2-in_y1;

        dist = sqrt(deltaX.^2 + deltaY.^2);
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
        
        function [dist,pointDist] = getTripDist(obj,option,ID)
            if strcmp(option,'TripID')
                index = find(sum(obj.TripID==(ID'),2));
            elseif strcmp(option,'TripIndex')
                index = ID;
            else 
                fprintf('not valid option\n');
            end
            
            previousGPS = obj.TripInCell{index}(1:end-1,[3 4]);
            nextGPS = obj.TripInCell{index}(2:end,[3 4]);
            pointDist = disMethod4(previousGPS(:,1),previousGPS(:,2), ...
                nextGPS(:,1),nextGPS(:,2));            
            dist = sum(pointDist);
        end
        
        function index = getTripID(obj,option,ID)
             if strcmp(option,'TripID')
                index = find(sum(obj.TripID==(ID'),2));
            elseif strcmp(option,'TripIndex')
                index = obj.TripID(ID);
            else 
                fprintf('not valid option\n');
             end       
        end
        
         function [index,problemFlag,tripInfo] = findTripWithAttr(obj,option)
            %index = findTripWithAttr(obj,option) 
            %input: option.maxSpeed (m/s) <- speed limit for the trip
            %       option.indexRange <- tripIndex (row index) 
            %       option.addr (ex. 'AnnArbor')<- specify the region you wanted
            %       option.dist (ex. [5 10] (km))<- specify the range of dist you wanted
            %output: vector of tripIndex
            
            [index,problemFlag,tripInfo] = gofindTripWithAttr(obj,option);
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
        
        
        
        day1_Obj = obj;    
        [index,gpsAddress,meanspeed] = inspectTripAttr(day1_Obj,option,ID,varargin);
       
        end
        
        function obj = downSample(obj,option) 
            %obj = downSample(obj,option) 
            %option.sampleRate: integer: 0 to 1 which is the frequency ratio
            %        to the dataset which 1/sampleRate is a integer
            %     eg.orig_freq = 10Hz ,tar_freq = 5 Hz, 
            %        samplerate = tar_freq/orig_freq = 0.5 
            %        and 1/0.5 = 2(integer)
            %option.algortihm: 'moving'/'lowess'/'loess'
            %option.windowSize: integer 
            %recommend: moving: windowsize<-11
            %(for 10Hz) loess : windowsize<-15
            if nargin == 1
                option.sampleRate = 1;
                option.algorithm = 'moving';
                option.windowSize = 11;
            end
            obj = goDownSample(obj,option);
        end
    end
end

