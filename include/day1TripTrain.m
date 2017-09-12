classdef day1TripTrain < day1TripAnalysis
    properties
        Start
        LocalTripCell
        GPSMode
        TripSTD
        TripZone
    end
    methods
        function obj = day1TripTrain(day1F_Re)
            obj = obj@day1TripAnalysis(day1F_Re);
            obj.Start = [];
            obj.LocalTripCell  =[];  
            obj.GPSMode = 'normal';
            obj.TripSTD = [];
            obj.TripZone = [];
                
        end
        
        function obj = trainningMode(obj,gpsMode,option)
            % trainningMode(obj,gpsMode,option)
            % option: 'zeroBegin' to allow trip start with zero 
            % gpsMode: 'UTM' to get UTM coordinate, 'normal' to get
            % normalize GPS value
            if nargin == 1
                gpsMode = 'normal';
                option = 'zeroBegin';
            end
            
            if nargin == 2
                option = 'zeroBegin';
            end
            if strcmp(option,'zeroBegin')
                
                if strcmp(gpsMode,'normal') 
                obj.GPSMode = 'normal';
                obj.Start = getStartGPS(obj);
                [obj.LocalTripCell,~,obj.TripSTD] = getLocalInCell(obj);
                obj.Log  = [obj.Log; ['normalize data at ' datestr(now)]];
                elseif strcmp(gpsMode,'UTM')
                    [obj.LocalTripCell,obj.Start,obj.TripSTD,obj.TripZone] = getLocalInCell(obj,gpsMode);
                    obj.GPSMode = 'UTM';
                    obj.Log = [obj.Log; ['normalize data with UTM at ' datestr(now)]];
                else 
                    error('invalid option for gpsMode');
                end
            end           
        end
         
        function [trainSet,valSet] = genSegSet(obj,trainParam)
            % get segmented training/testing data
            % trainParam.in_attr;
            % trainParam.tar_delay;
            % trainParam.windowSize;
            % trainParam.randomSeed;
            % trainParam.hiddenUnit;
            % trainParam.KFold
            % trainParam.K
            
            
            % initialize param
            numTrip = length(obj.TripLen);
            in_attr = trainParam.in_attr;
            out_attr = trainParam.out_attr;
            tar_delay = trainParam.tar_delay;
            windowSize = trainParam.windowSize;
            K = trainParam.K;
            KFold = trainParam.KFold;
            %randomSeed = trainParam.randomSeed;
            %hiddenUnit = trainParam.hiddenUnit;
            
            %step 0.selectfeat           
            attrNum = out_attr;
            in_y = cellfun(@(x) x(:,attrNum),obj.LocalTripCell,'UniformOutput',0);
            attrNum = in_attr;
            in_x =  cellfun(@(x) x(:,attrNum),obj.LocalTripCell,'UniformOutput',0);
            
            %step 1.extractSeg
            in_x = cellfun(@(x) extractCellSeg(x,windowSize,tar_delay),in_x,'UniformOutput',0); 
            in_y = cellfun(@(x) x((tar_delay+windowSize):end,:)- ...
                                x(1:end-(tar_delay)-windowSize+1,:), ...
                                in_y,'UniformOutput',0);
           
                      
            %step 2.gen train /test set
            try 
                randomSeed = trainParam.randomSeedIdx;
            catch
                randomSeed = 1;
            end
            randSeed = loadRandomSeed(randomSeed);
            rng(randSeed);
            randIdx = randperm(numTrip);
            [KFoldIdx] = KfoldIndex(randIdx,KFold);
            [trainIdx,valIdx] = KfoldIndexOut(KFoldIdx,K);
            
            
            trainSet.in_x  = in_x(trainIdx);
            trainSet.in_y = in_y(trainIdx);
            trainSet.idx = trainIdx;
            valSet.in_x = in_x(valIdx);
            valSet.in_y = in_y(valIdx);
            valSet.idx = valIdx;
        end
            
            
         function [testY,trainY,errorMeasure,net] = trainSeg(obj,trainSet,testSet,trainParam,net)
             
            % initialize param
            randomSeed = trainParam.randomSeed;
            hiddenUnit = trainParam.hiddenUnit;
            trainFcn = trainParam.trainFcn;
            performFcn = trainParam.performFcn;
            divideFcn = trainParam.divideFcn;
            divideParam = trainParam.divideParam;
            mu = trainParam.mu;
            epochs = trainParam.epochs;
            max_fail = trainParam.max_fail;
            trainRatio = divideParam.trainRatio;
            valRatio = divideParam.valRatio;
            testRatio = divideParam.testRatio;
            showWindow = trainParam.showWindow;
            min_grad = trainParam.min_grad;
            goal = trainParam.goal;
            regularization = trainParam.regularization;
           
            %2.gen train /test set
            trainSet.in_x = cell2mat(trainSet.in_x);
            trainSet.in_y = cell2mat(trainSet.in_y);
            testSet.in_x = cell2mat(testSet.in_x);
            testSet.in_y = cell2mat(testSet.in_y);
            
            %3. training
            if nargin<5
            net = feedforwardnet(hiddenUnit);
            net.trainFcn = trainFcn;
            net.trainParam.mu = mu;
            net.trainParam.epochs = epochs;
            net.trainParam.max_fail = max_fail;
            net.performFcn = performFcn;
            net.trainParam.divideFcn = divideFcn;
            net.divideParam.trainRatio = trainRatio;
            net.divideParam.valRatio = valRatio;
            net.divideParam.testRatio = testRatio;
            net.trainParam.showWindow=showWindow;
            net.trainParam.min_grad=min_grad;
            net.trainParam.goal = goal;
            net.performParam.regularization = regularization;
            end
            randSeed = loadRandomSeed(randomSeed);
            rng(randSeed);
            net = configure(net,trainSet.in_x',trainSet.in_y');
            net.iw{1} = net.iw{1}.*0.01;
            net.lw{2} = net.lw{2}.*0.01;
            try 
                net.lw{6}  = net.lw{6}.*0.01;
            end
            [net,tr] = train(net,trainSet.in_x',trainSet.in_y');
            trainY = net(trainSet.in_x');
            testY = net(testSet.in_x');
            
            %for lat and lng dist
            testerr = obj.distance2Point(testSet.in_y(:,1),testSet.in_y(:,2),...
                testY(1,:)',testY(2,:)');
            trainerr = obj.distance2Point(trainSet.in_y(:,1),trainSet.in_y(:,2),...
                trainY(1,:)',trainY(2,:)');
            
            errorMeasure.testerr = rms(testerr(:));
            errorMeasure.trainerr = rms(trainerr(:));
            
            lenY = size(testY,1);
            %for other attri
            if lenY > 2
                for out_attr_idx = 3:lenY
                    switch obj.TripAttr{trainParam.out_attr(out_attr_idx)}
                        case 'Speed'
                            testerror = (testY(out_attr_idx,:)'*10+10)- ...
                                (testSet.in_y(:,out_attr_idx)*10+10);
                            trainerror = (trainY(out_attr_idx,:)'*10+10)- ...
                                (trainSet.in_y(:,out_attr_idx)*10+10);
                            errorMeasure.(['testerr_col' num2str(out_attr_idx)]) = rms(testerror(:));
                            errorMeasure.(['trainterr_col' num2str(out_attr_idx)]) = rms(trainerror(:));
                         case 'Heading'
                            testerror = rad2deg(testY(out_attr_idx,:)'+pi)- ...
                                rad2deg(testSet.in_y(:,out_attr_idx)+pi);
                            trainerror = rad2deg(trainY(out_attr_idx,:)'+pi)- ...
                                rad2deg(trainSet.in_y(:,out_attr_idx)+pi);
                            errorMeasure.(['testerr_col' num2str(out_attr_idx)]) = rms(testerror(:));
                            errorMeasure.(['trainterr_col' num2str(out_attr_idx)]) = rms(trainerror(:));
                    end
                        
                end
            end
                
                
                
            
            if showWindow
                disp(errorMeasure);
            end
            %savestr = ['../model/modelError-' datestr(now,'yyyymmdd_HHMMSS') '.mat'];
            %save(savestr,'testErr','tr','net');
            
            
            %disp(errorMeasure.testerr);
            
           % pause();
            
         end
        
        function [GPSout_Ytr,GPSout_x] = retrieveGPSfromSeg(obj,trainSet,Ytr,trainParam)
            
            windowSize = trainParam.windowSize;
            tar_delay = trainParam.tar_delay;
            attrNum = [3 4]; % GPS attr col
            attrLen = length(attrNum);
            %selectfeat           
            in_x =  cellfun(@(x) x(:,attrNum),obj.LocalTripCell,'UniformOutput',0);
            
            %extractSeg
            option = 'keep';
            in_x_Seg = cellfun(@(x) extractCellSeg(x,windowSize,tar_delay,option),in_x,'UniformOutput',0); 
            
            start_x = mat2cell(obj.Start,ones(100,1),2);
            
            in_x = cellfun(@(a,b) bsxfun(@plus,a,repmat(b,1,windowSize)),in_x_Seg,start_x,'UniformOutput',0); 
            in_x = cellfun(@(x) reshape(x',2,[])',in_x,'UniformOutput',0);
            in_x = cellfun(@(a,b) reshape(utm2ll(a(:,2),a(:,1),b)',windowSize*attrLen,[])', ...
                           in_x,obj.TripZone,'UniformOutput',0);
            in_x = in_x(trainSet.idx);
            in_x_list = cell2mat(in_x);
            
            GPSout_x.TripInCell = in_x;
            GPSout_x.idx = trainSet.idx;
            GPSout_x.list = in_x_list;
            
           
            in_y = cellfun(@(x) x(windowSize+tar_delay:end,attrNum),obj.TripInCell,'UniformOutput',0);
            in_y = in_y(trainSet.idx);
            GPSout_x.GTCell = in_y;


            GPSout_Ytr = [];
            Ytr = Ytr';
            currentIdx = 1;
            numTrip = length(trainSet.idx);
            outCell = cell(numTrip,1);
            for tripIdx = 1:numTrip
                tripIndex = trainSet.idx(tripIdx);
                tripLen = obj.TripLen(tripIndex);
                tripStart = obj.Start(tripIndex,:);
                index = currentIdx:currentIdx+tripLen-windowSize-tar_delay;
                if size(Ytr,2)>2
                    outCell{tripIdx} = [bsxfun(@plus,Ytr(index,[1 2]),tripStart) Ytr(index,3:end)];
                else 
                    outCell{tripIdx} = bsxfun(@plus,Ytr(index,:),tripStart);
                end
                currentIdx = currentIdx+tripLen-windowSize-tar_delay+1;
            end
            if size(Ytr,2)>2
                outCell = cellfun(@(a,b) [a(:,[1 2])+b(:,[1 2]) a(:,3:end)], outCell,in_x_Seg(trainSet.idx),'UniformOutput',0);
                outCell = cellfun(@(a,b) [utm2ll(a(:,2),a(:,1),b) a(:,3:end)],outCell,obj.TripZone(trainSet.idx),'UniformOutput',0);
            else
                outCell = cellfun(@(a,b) a+b(:,[1 2]), outCell,in_x_Seg(trainSet.idx),'UniformOutput',0);
                outCell = cellfun(@(a,b) utm2ll(a(:,2),a(:,1),b),outCell,obj.TripZone(trainSet.idx),'UniformOutput',0);
            end
                
            GPSout_Ytr.TripInCell = outCell;
            GPSout_Ytr.idx = trainSet.idx;
            GPSout_Ytr.list = cell2mat(outCell);
            
            
           
            
            
            
        end
             
             
             
        
        function obj = addTripInfo(obj,attrName,data)
            % obj = addTripInfo(obj,attrName,data)
            % add attribute and data into TripInfo
            obj.TripInfo = [obj.TripInfo array2table(data,... 
                'VariableNames',{attrName})];
            
            obj.Log = [obj.Log;['adding ' attrName ' to TripInfo. Created at ' ...
                datestr(now)]];            
        end
        
        function tripInfo = getTripWithAttr(obj,attrNum)
            % tripInfo = getTripWithAttr(obj,attrNum)
            % attrNum is N by 1 vector for attribute selection
            if isempty(obj.LocalTripCell)
                error('please try using .trainningMode');
            end
        
            numTrip = length(obj.TripID);
            numAttr = length(attrNum);
            tripInfo = cell(numTrip,1);
            for i = 1:numTrip
                tripLen = obj.TripLen(i);
                tripInfo(i) = {mat2cell(obj.LocalTripCell{i}(:,attrNum)',numAttr,ones(1,tripLen))};
            end
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
        
        function [acc2DistRatio, yawRate2DistRatio] = getTripDifficulty(obj,option,ID)
            if strcmp(option,'TripID')
                index = find(sum(obj.TripID==(ID'),2));
            elseif strcmp(option,'TripIndex')
                index = ID;
            else 
                fprintf('not valid option\n');
            end
             
             thisTripDist = obj.getTripDist('TripIndex',index);
             thisAcc = rms(diff(obj.TripInCell{index}(:,6)));
             acc2DistRatio = thisAcc/thisTripDist*10;
             thisYaw = rms(obj.TripInCell{index}(:,11));
             yawRate2DistRatio = thisYaw/thisTripDist;
                     
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
        
        function freq = getDataFreq(obj)
        % to get the frequency of dataset by assess the time interval
            dataTS = 100000; % time units in us
            freq = round(1/(mean(diff(obj.TripInCell{1}(:,end)))/(10*dataTS)));
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
        
        function dist = distance2Point(obj,in_x1,in_y1,in_x2,in_y2)
        deltaX = in_x2-in_x1;
        deltaY = in_y2-in_y1;

        dist = sqrt(deltaX.^2 + deltaY.^2);
        end
        
        function [errMeasurement,checkpoint] = trainKFold(obj,trainParam,errMeasurement,checkpoint)
            % [errMeasurement,checkpoint] = trainKFold(obj,trainParam,errMeasurement,checkpoint) 
            % have a K-fold network training with the parameter
            % initialization
            % 
            %{
            checkpoint.current = 0;
            checkpoint.count = 1;
            checkpoint.save = 0;

            trainParam.delayindex = 3:3;
            trainParam.windowSize = 5:5;
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
            %}
            [errMeasurement,checkpoint] = goTrainKFold(obj,trainParam,errMeasurement,checkpoint);
        end
        
        function [errMeasurement,checkpoint] = trainSegKFold(obj,trainParam,errMeasurement,checkpoint)
            % K-fold crossvalidation on segmentation method
            % list of training parameter to be initialized
            %{
            trainParam.in_attr = [3 4]; 
            trainParam.tar_delay = [6];
            trainParam.windowSize = 10;
            trainParam.randomSeed = 5;
            trainParam.hiddenUnit = 25;
            trainParam.mu = 0.01;
            trainParam.epochs = 1000;
            trainParam.trainfcn = 'trainlm';
            trainParam.divideFcn = 'divideblock' ;
            divideParam.trainRatio = 0.75;
            divideParam.valRatio = 0.25;
            divideParam.testRatio = 0;
            trainParam.divideParam = divideParam;
            trainParam.showWindow=1;
            trainParam.max_fail=10;
            trainParam.min_grad=1e-7;
            trainParam.goal = 1e-9;
            trainParam.GPSMode = 'UTM';
            trainParam.KFold = 4;
            %}
            [errMeasurement,checkpoint] = goTrainSegKFold(obj,trainParam,errMeasurement,checkpoint);
            

            
        end
    end
end

function startGPS = getStartGPS(trip_obj)
numTrip = length(trip_obj.TripID);
startGPS = zeros(numTrip,2);
for i = 1:numTrip
    startGPS(i,:) = trip_obj.TripInCell{i}(1,[3 4]);    
end
end

function day1_10Hz_Train = goDownSample(day1_10Hz_Train,option)
if mod(1/option.sampleRate,1)~=0
    error('invalid sampleRate option, 1/sampleRate should be integer');
end
alg = option.algorithm;
windowSize = option.windowSize;
tripAttr = 3:13; % from lat,lng,heading,spd,...

% cleanUp the raw data respect to the time stamp
TripInCell = day1_10Hz_Train.TripInCell;
% resample the in-uniform data based on the time in second
dataTS = 100000;
timeStampCell = cellfun(@(x) {(x(:,end)-x(1,end))./(10*dataTS)},TripInCell); % get time info
Fs = round(1/mean(diff(timeStampCell{1})));
disp([  'dataset using to perform downsample is ' num2str(Fs) ' Hz']);
% resample all the info of the trip by the time stamp
% resample on lat to get the len of trip info
for i = 1:length(timeStampCell)
lat = resample(TripInCell{i}(:,3),timeStampCell{i},Fs);
resampleLen = length(lat);
attrResample = [];
    for attrnum = 3:13
    attrResample = [attrResample ...
    resample(TripInCell{i}(:,attrnum),timeStampCell{i},Fs)];
    end
timeResample = (((1:resampleLen).*dataTS)+round(TripInCell{i}(1,end),-5))';
attrResample = [repmat(TripInCell{i}(1,[1 2]),resampleLen,1) ...
                attrResample ...
                timeResample];
TripInCell{i} =  attrResample;
end

% perform median filter
medfiltSize = 5;
TripInCell = cellfun(@(x) {[x(:,[1 2]) ...
                            medfilt1(x(:,3),medfiltSize) ...
                            medfilt1(x(:,4),medfiltSize) ...
                            x(:,5:end)]},TripInCell);
% perform filter from option
TripInCell = cellfun(@(x) {[x(:,[1 2]) ...
                            smooth(x(:,3),windowSize,alg) ...
                            smooth(x(:,4),windowSize,alg) ...
                            x(:,5:end)]},TripInCell);

% downsample by interpolation
TripInCell =cellfun(@(x) {x(1:1/option.sampleRate:end,:)},TripInCell);

% output resampled data
day1_10Hz_Train.TripInCell = TripInCell;
day1_10Hz_Train.TripLen = cellfun(@(x) length(x(:,1)),TripInCell);    
day1_10Hz_Train.Log = [day1_10Hz_Train.Log ;
                        ['Data is filtered using ''' alg ''' with sample rate: ' ...
                          num2str(option.sampleRate) ' at ' datestr(now)]]; 
end

function featureCell = extractCellSeg(tripInCell,windowSize,tar_delay,option)
            %only substract the geo data (GPS)
            if nargin<4
                option = 'subtract';
            end
            
            [tripLen,featuredim] = size(tripInCell);
            featureCell = zeros(tripLen-windowSize-tar_delay+1,windowSize*featuredim);
            if strcmp(option,'subtract')
                for timeStamp = 1:tripLen-windowSize-tar_delay+1
                    thisfeatCell = bsxfun(@minus,tripInCell(timeStamp:timeStamp+windowSize-1,:), ...
                        [tripInCell(timeStamp,[1 2]) zeros(1,size(tripInCell,2)-2)]);


                    featureCell(timeStamp,:) = reshape(thisfeatCell',1,[]);
                end
            elseif strcmp(option,'keep')
                for timeStamp = 1:tripLen-windowSize-tar_delay+1
                    thisfeatCell = tripInCell(timeStamp:timeStamp+windowSize-1,:);
                    featureCell(timeStamp,:) = reshape(thisfeatCell',1,[]);
                end
            end                
end

function  [localInCell,tripStart,gpsSTD,tripZone,tripInfo] = getLocalInCell(trip_obj,gpsMode)
if nargin == 1 
    gpsMode = 'normal';
    tripStart = [];
    tripZone = [];
end
numTrip  = length(trip_obj.TripID);
localInCell = cell(numTrip,1);
if strcmp(gpsMode,'UTM')
    tripStart = zeros(numTrip,2);
    %gpsSTD = [1058 1227];
    %disp('debug value on gpsSTD');
    gpsSTD = [1 1];
    tripZone = cell(numTrip,1);
elseif strcmp(gpsMode,'normal')
    tripStart = [];
    %paramter here approximation for ann arbor region
    gpsSTD = [0.1 0.14];  %0.1 is city level/0.01 is town level
end
    
tripInfo = [];

speedMean = 20/2;     %local speed
speedSTD  = 10;
elevationMean = 230;
elevationSTD = 20;
%gpsLocal =  [42.3053253 -83.6694169]; % ann arbor
gpsLocal = []; 



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
      thisTripGPS = bsxfun(@times,bsxfun(@minus,thisTrip(:,[3 4]),gpsLocal),1./gpsSTD);
    end
    %To normalize speed ~[0 20] (m/s) (local road) std~10
    thisTripSpeed = (thisTrip(:,[6])-speedMean)./speedSTD;
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
    thisTripYawrate = thisTrip(:,[11]);
    %To normalize ROC radius of curve need to work on it    
    thisTripROC = thisTrip(:,[12]);
      %thisTripROC(abs(thisTripROC)>100&abs(thisTripROC)<=500)=100;
    thisTripROC((thisTripROC<1) & (thisTripROC>0),:)=1;
    thisTripROC((thisTripROC<0) & (thisTripROC>-1))=-1;
    thisTripROC(thisTripROC==0) = 5000;
    if (sum(thisTripROC==0) +  sum(abs(thisTripROC)<1))>0
        warning(['trip index' num2str(i) 'ROC value is abnormal']);
    end
        
    thisTripROC = 10./thisTripROC;
    
    %To normalize confidence (percentage)
    thisTripConfidence = thisTrip(:,[13])./100 -0.5;
    %time
    thisTripTime = thisTrip(:,[14]);
    
    localInCell{i} = [ thisTripID, thisTripGPS, thisTripElevation, ...
        thisTripSpeed, thisTripHeading, ...
        thisTripAx, thisTripAy, thisTripAz, thisTripYawrate, ...
        thisTripROC, thisTripConfidence, thisTripTime];
end
    

end





function [index,problemFlag,tripInfo] = gofindTripWithAttr(tripTrain_obj,option)
%filterParameter
maxSpeed=option.maxSpeed;
indexRange = option.indexRange;
addr = option.addr;
dist = option.dist;
index = [];
problemFlag = zeros(length(indexRange),5);
%filterParameter (default value)
AxMax = 10;
AyMax = 10;
AzMax = 8;
timeDiff = -1000000; %(1s)
tripInfo.addr = {};
tripInfo.index = [];
tripInfo.dist = [];
tripInfo.maxSpeed = [];


j=1;
for i = indexRange
   skipFlag = 0;
   speedFlag = 0;
   distFlag = 0;
   addrFlag = 0;
   timeFlag = 0;    
   
   
   thisTrip = tripTrain_obj.TripInCell{i};
   %filter timeDiff
   thisTripTimeDiff = thisTrip(1:end-1,14) - thisTrip(2:end,14);
   ifDisCont = find(thisTripTimeDiff ~= timeDiff, 1);
   if ~isempty(ifDisCont)
       skipFlag = 1;
       timeFlag = 1;
   end
   if skipFlag ~= 1
       %filter speed,ax,ay,az
       if (max(thisTrip(:,6))>maxSpeed || max(abs(thisTrip(:,8)))>AxMax || ...
           max(abs(thisTrip(:,9)))>AyMax || max(abs(thisTrip(:,10)))>AzMax)
           skipFlag = 1;
           speedFlag =1;
       end
       if skipFlag~=1 
           if ~isempty(dist)
               thisTripDist = tripTrain_obj.getTripDist('TripIndex',i);
                if thisTripDist>dist(2) || thisTripDist<dist(1)                    
                    skipFlag = 1;
                    distFlag = 1;
                end
           end
           if ~isempty(addr)
               if skipFlag~=1 
                   thisTripAddr = tripTrain_obj.getTripAddr('TripIndex',i);
                    if ~contains(thisTripAddr,addr)
                        skipFlag = 1;
                        addrFlag = 1;
                    end
               end
           end
           if skipFlag==0
               index = [index i];
               tripInfo.index = index;
               if ~isempty(addr)
               tripInfo.addr = [tripInfo.addr;[thisTripAddr]];
               end
               tripInfo.dist = [tripInfo.dist thisTripDist];
               tripInfo.maxSpeed = [tripInfo.maxSpeed max(thisTrip(:,6))];
           end

       end
   end
   
   problemFlag(j,:) = [i timeFlag speedFlag distFlag addrFlag];
   j=j+1;
end
           
      
end

function [errMeasurement,checkpoint] = goTrainKFold(obj,trainParam,errMeasurement,checkpoint)

day1F_train = obj;
option.save = checkpoint.save;
%{
trainParam.divideFcn = 'divideblock' ;
trainParam.divideParam.trainRatio = 80/100;
trainParam.divideParam.valRatio   = 20/100;
trainParam.divideParam.testRatio  = 0/100;
trainParam.epochs = 2000-125*(netPara.windowSize-2);
trainParam.showWindow=1;
trainParam.max_fail=10;
trainParam.min_grad=1e-7;
trainParam.goal = 1e-9;
trainParam.option = option;
%}


for i = trainParam.delayindex  %delay
   for j = trainParam.windowSize %windowSize
       for l = trainParam.hiddenLayer %hidden layer
            for k = trainParam.randomSeed %1:5 %randomSeed
               if checkpoint.count>checkpoint.current
                   if checkpoint.count == checkpoint.current+1
                       checkpoint.count
                   end
                   
                   %   
                   %i =3 ;j=5;k=2;l=7;
            delay = i;
            windowSize = j;
            inputDelays = delay:windowSize+delay-1;
            feedbackDelays = delay:windowSize+delay-1;
            hiddenLayerSize = l;
            net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);
            net = removedelay(net,delay);
            net.trainFcn = trainParam.trainFcn;
            %net.layers{1}.transferFcn = '';
            net.layers{1}.transferFcn = trainParam.layerTransferFcn;
            %net.layers{2}.transferFcn = 'logsig';

            %net.layerConnect(1,1)=1;
            %net.layerWeights{1}.delays=1;
            %view(net);
            netPara.delay =delay;
            netPara.windowSize = windowSize;

            % select training trip test for gps as baseline
            %select trip
            attrNum = trainParam.y_attr;
            in_y = day1F_train.getTripWithAttr(attrNum);
            %thisTrip = mat2cell(([1:8;(1:8).*2]),2,ones(1,8));
            %attrNum = [5:13 16:17];
            attrNum = trainParam.x_attr;
            %attrNum =[];
            in_x =  day1F_train.getTripWithAttr(attrNum);
            K = trainParam.numKFold;
    
            % K-fold
            option.randomSeed = k;
            option.netPara = netPara;
            trainParam.option = option;
            
            [errorMeter,filename] = KfoldError(net,K,in_x,in_y,day1F_train,trainParam);

            errorValue = mean(errorMeter(1:4,5).Variables);
            if isempty(attrNum)
                attrNum = 0;
            end
            if option.save
            errMeasurement = [ errMeasurement ;...
                {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
                 num2str(hiddenLayerSize),num2str(option.randomSeed), ...
                 num2str(errorValue,'%.10f'),num2str(attrNum)}]
             save ../model/errMeasurement.mat errMeasurement
            else 
             [  {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
                 num2str(hiddenLayerSize),num2str(option.randomSeed), ...
                 num2str(errorValue,'%.10f'),num2str(attrNum)}]
            end
            
           
           %errMeasurement(k*j,:) = ...
           %     {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
           %      num2str(hiddenLayerSize),num2str(option.randomSeed), ...
           %      num2str(errorValue,'%.10f')}
           % save ../model/errMeasurement.mat errMeasurement 
            
               end
            checkpoint.count = checkpoint.count + 1;
            end
        end
    end
end


end

    


function [errMeasurement,checkpoint] = goTrainSegKFold(obj,trainParam,errMeasurement,checkpoint)

%day1F_2Hz_Train= obj;
option.save = checkpoint.save;
%{
trainParam.divideFcn = 'divideblock' ;
trainParam.divideParam.trainRatio = 80/100;
trainParam.divideParam.valRatio   = 20/100;
trainParam.divideParam.testRatio  = 0/100;
trainParam.epochs = 2000-125*(netPara.windowSize-2);
trainParam.showWindow=1;
trainParam.max_fail=10;
trainParam.min_grad=1e-7;
trainParam.goal = 1e-9;
trainParam.option = option;
%}


for i = trainParam.tar_delay  %delay
   for j = trainParam.windowSize %windowSize
       for l = 1:length(trainParam.hiddenUnit) %hidden layer
            for k = trainParam.randomSeed %1:5 %randomSeed
               if checkpoint.count>checkpoint.current
                   if checkpoint.count == checkpoint.current+1
                       checkpoint.count
                       [i j trainParam.hiddenUnit{l} k]
                   end
                   
            delay = i;
            windowSize = j;
            hiddenUnit = trainParam.hiddenUnit{l};
            attrNum = trainParam.in_attr;
            net = feedforwardnet(hiddenUnit);
            net.trainFcn = trainParam.trainFcn;
            net.layers{1}.transferFcn = trainParam.layerTransferFcn;
            net.trainParam.mu = trainParam.mu;
            net.trainParam.epochs = trainParam.epochs;
            net.trainParam.max_fail = trainParam.max_fail;
            net.performFcn = trainParam.performFcn;
            net.divideParam.trainRatio = trainParam.divideParam.trainRatio;
            net.divideParam.valRatio = trainParam.divideParam.valRatio;
            net.divideParam.testRatio = trainParam.divideParam.testRatio;
            net.trainParam.showWindow = trainParam.showWindow;
            net.trainParam.min_grad= trainParam.min_grad;
            net.trainParam.goal = trainParam.goal;
            net.performParam.regularization = trainParam.regularization;
            
            %net.layers{2}.transferFcn = 'logsig';

            %net.layerConnect(1,1)=1;
            %net.layerWeights{1}.delays=1;
            %view(net);
            netPara.delay =delay;
            netPara.windowSize = windowSize;

            % select training trip test for gps as baseline
            %select trip
            %[trainSet,valSet] = genSegSet(obj,trainParam);            
            
    
            % K-fold
            option.randomSeed = k;
            option.netPara = netPara;
            trainParam.option = option;
            
            foldTrainParam = trainParam;
            foldTrainParam.tar_delay = delay;
            foldTrainParam.windowSize = windowSize;
            foldTrainParam.randomSeed = k;
            foldTrainParam.hiddenUnit = hiddenUnit;
            
            
            [errorMeter,filename] = segKfoldError(net,obj,foldTrainParam);

            errorValue = mean(errorMeter{1:4,3});
            
            
            if isempty(attrNum)
                attrNum = 0;
            end
            if option.save
            errMeasurement = [ errMeasurement ;...
                {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
                 num2str(hiddenUnit),num2str(option.randomSeed), ...
                 num2str(errorValue,'%.10f'),num2str(attrNum)}]
             save ../model/errMeasurement.mat errMeasurement
            else 
             [  {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
                 num2str(hiddenLayerSize),num2str(option.randomSeed), ...
                 num2str(errorValue,'%.10f'),num2str(attrNum)}]
            end
            
           
           %errMeasurement(k*j,:) = ...
           %     {filename,num2str(netPara.delay),num2str(netPara.windowSize), ...
           %      num2str(hiddenLayerSize),num2str(option.randomSeed), ...
           %      num2str(errorValue,'%.10f')}
           % save ../model/errMeasurement.mat errMeasurement 
            
               end
            checkpoint.count = checkpoint.count + 1;
            end
        end
    end
end
end

function [Kfold] = KfoldIndex(tripIndex,K)
Kfold = cell(K,1);
numberIndex = length(tripIndex);
rowIndex = 1;
numberInKfold = floor(numberIndex/K);
for i = 1:K
    
    if i<K
    index = rowIndex:rowIndex+numberInKfold-1;
    Kfold{i} = tripIndex(index);
    else 
        Kfold{i} = tripIndex(rowIndex:end);
    end
    rowIndex = rowIndex+numberInKfold;
end
end
        
function [trainSetIndex,testSetIndex] = KfoldIndexOut(Kfold,number)
K = length(Kfold);
trainSetIndex = [];
for i = 1:K
    if i ~= (K-number+1) 
    trainSetIndex = [trainSetIndex Kfold{i}];
    else 
        testSetIndex = Kfold{i};
    end
end
end
    
            
        
        