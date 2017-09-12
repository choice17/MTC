classdef day1TripTrainSeg 
    properties
        GPSMode
        TripZone
        TripID
        TripInCell
        TripLen
        TripAttr
        Log
        LocalTripCell
    end
    methods
        function obj = day1TripTrainSeg(day1_Obj) 
            obj.GPSMode = day1_Obj.GPSMode ;
            obj.TripZone = day1_Obj.TripZone;
            obj.TripInCell = day1_Obj.TripInCell;
            obj.TripID = day1_Obj.TripID;
            obj.TripAttr = day1_Obj.TripAttr;
            obj.TripLen = day1_Obj.TripLen;
            obj.Log = [day1_Obj.Log;['created day1TripTrainSeg obj at' ...
                ' ' datestr(now)]];
           
        end
        
        function obj = trainSeg(obj,trainParam)
            
            % initialize param
            numTrip = length(obj.TripLen);
            in_attr = trainParam.in_attr;
            out_attr = [3 4];
            tar_delay = trainParam.tar_delay;
            windowSize = trainParam.windowSize;
            randomSeed = trainParam.randomSeed;
            
            %0.selectfeat           
            attrNum = out_attr;
            in_y = obj.getTripWithAttr(attrNum);
            attrNum = in_attr;
            in_x =  obj.getTripWithAttr(attrNum);
            
            %1.extractSeg
            in_x = cellfun(@(x) extractCellSeg(x,windowSize,tar_delay),in_x); 
            in_y = cellfun(@(x) x((tar_delay+windowSize):end,:),in_y);
           
                      
            %2.gen train /test set
            randSeed = loadRandomSeed(trainParam.randomSeed);
            rng(randSeed);
            randIdx = randperm(numTrip);
            trainSetIndex = randIdx(1:63);
            testSetIndex = randIdx(64:end);
                                   
            trainSet,testSet = getTrainTestSet(in_x,in_y,trainSetIndex,testSetIndex);
            
            
            %3. training
            
            net = feedforwardnet();
        end

            
           
            
            
            
        
        
        function extractSeg(tripInCell,windowSize,tar_delay)
            [tripLen,featuredim] = size(tripInCell);
            featureCell = zeros(tripLen-windowSize-tar_delay+1,windowSize*featuredim);
            for timeStamp = 1:tripLen-windowSize-tar_delay+1
                featureCell(timeStamp,:) = reshape(tripInCell(timeStamp:timeStamp+windowSize,:), ...
                    1, []);
            end
        end
                
    end
end
            