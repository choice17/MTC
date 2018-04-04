classdef day1TripTrain < day1TripAnalysis
    % day1TripTrain < day1TripAnalysis
    % Object: subclass of day1TripAnalysis, mainly for training section
    %         - time series training section
    %         - segment feature extraction for x-y coord time series data in
    %         feed forward neural network training
    % Properties:
    %         Start         - Starting value when doing feature extraction
    %                         for data normalization purpose
    %         LocalTripCell - Trip data split into cell respective to
    %                         different trip number after normalization
    %         GPSMode       - current GPS Mode 
    %         TripSTD       - Sztandard derivation value of the data, for
    %                         data normalization purpose
    %         TripZone      - TripZone ( only specify for UTM Mode)
    % Methods:
    %         day1TripTrain()
    %         trainningMode()
    %         genSegSet()
    %         trainSeg()
    %         retrieveGPSfromSeg()
    %         addTripInfo()
    %         getTripWithAttr()
    %         getDataFreq()
    %         getTripDifficulty()
    %         trainKFold()
    %         trainSegKFold()
    %         downSample()
    
    properties (Access = public)
        Start  
        LocalTripCell
        GPSMode
        TripSTD
        TripZone
        NormInfo
    end
    properties (Access = private)
        % to access by calling get/set
        model
        model_parameter
        model_OffTraining
        
        % internal use
        trPredRe
        trSetRe
        trainSet
        Ytr
    end
    
    methods (Access = public)
        function obj = day1TripTrain(day1F_Re)
            
            % day1TripTrain constructor
            
            if nargin == 1
            % Provide values for superclass constructor
                args = day1F_Re;
            elseif nargin == 0
            % overload empty input to output empty object    
                args = [];
            end
            
            obj = obj@day1TripAnalysis(args);           
                       
            obj.Start = [];
            obj.LocalTripCell  =[];  
            obj.GPSMode = 'normal';
            obj.TripSTD = [];
            obj.TripZone = [];  
            obj.model = [];
            obj.model_parameter = [];
            obj.model_OffTraining = 0;
            obj.trPredRe = [];
            obj.trSetRe = [];
                
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
                    obj = getLocalInCell(obj,gpsMode);
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
            
            if (K<=KFold)
                [KFoldIdx] = KfoldIndex(randIdx,KFold);
                [trainIdx,valIdx] = KfoldIndexOut(KFoldIdx,K);


                trainSet.in_x  = in_x(trainIdx);
                trainSet.in_y = in_y(trainIdx);
                trainSet.idx = trainIdx;
                valSet.in_x = in_x(valIdx);
                valSet.in_y = in_y(valIdx);
                valSet.idx = valIdx;
            else 
                trainSet.in_x  = in_x;
                trainSet.in_y = in_y;
                trainSet.idx = 1:numTrip;
                valSet.in_x = [];
                valSet.in_y = [];
                valSet.idx = [];
            end
        end
            
            
         function [testY,trainY,errorMeasure,net] = trainSeg(obj,trainSet,testSet,trainParam,net)
            
            %1.gen train /test set
            trainSet.in_x = cell2mat(trainSet.in_x);
            trainSet.in_y = cell2mat(trainSet.in_y);
            testSet.in_x = cell2mat(testSet.in_x);
            testSet.in_y = cell2mat(testSet.in_y);
            showWindow = trainParam.showWindow;
            
            if ~obj.model_OffTraining
                % 2.initialize param 
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
               
                min_grad = trainParam.min_grad;
                goal = trainParam.goal;
                regularization = trainParam.regularization;

                
                %3. training
                if nargin<5
                    if isa(hiddenUnit,'cell')
                        hiddenUnit = hiddenUnit{:};
                    end
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
                    %current only support two layer initialize
                    %can alter here to support more layer initialization
                try 
                    net.lw{6}  = net.lw{6}.*0.01;
                end
                try                 
                    if strcmp(trainParam.useParallel,'yes')
                        [net,tr] = train(net,trainSet.in_x',trainSet.in_y','useParallel','yes');
                    end
                catch
                    [net,tr] = train(net,trainSet.in_x',trainSet.in_y');
                end
            end
            
            trainY = net(trainSet.in_x');
            try
                testY = net(testSet.in_x');
            catch
                testY = [];
            end
            %for lat and lng dist
            if ~isempty(testSet.in_x) 
                testerr = obj.distance2Point(testSet.in_y(:,1),testSet.in_y(:,2),...
                    testY(1,:)',testY(2,:)').*(obj.NormInfo.gpsNorm(1));
            else 
                testerr = 0;
            end
            trainerr = obj.distance2Point(trainSet.in_y(:,1),trainSet.in_y(:,2),...
                trainY(1,:)',trainY(2,:)').*(obj.NormInfo.gpsNorm(1));
            
            errorMeasure.testerr = rms(testerr(:));
            errorMeasure.trainerr = rms(trainerr(:));
            
            lenY = size(testY,1);
            %for other attri
            if lenY > 2
                for out_attr_idx = 3:lenY
                    switch obj.TripAttr{trainParam.out_attr(out_attr_idx)}
                        case 'Speed'
                            if testerr~=0
                                testerror = (testY(out_attr_idx,:)'*obj.NormInfo.speedSTD)- ...
                                    (testSet.in_y(:,out_attr_idx)*obj.NormInfo.speedSTD);
                            else 
                                testerror = 0;
                            end
                                                                                    
                            trainerror = (trainY(out_attr_idx,:)'*obj.NormInfo.speedSTD)- ...
                                (trainSet.in_y(:,out_attr_idx)*obj.NormInfo.speedSTD);
                            errorMeasure.(['testerr_col' num2str(out_attr_idx)]) = rms(testerror(:));
                            errorMeasure.(['trainterr_col' num2str(out_attr_idx)]) = rms(trainerror(:));
                         case 'Heading'
                             
                            if testerr~=0 
                                testerror = rad2deg(testY(out_attr_idx,:)'+pi)- ...
                                    rad2deg(testSet.in_y(:,out_attr_idx)+pi);
                            else 
                                testerror = 0;
                            end
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
            
            % Debug code ------------------------------------------------
            %savestr = ['../model/modelError-' datestr(now,'yyyymmdd_HHMMSS') '.mat'];
            %save(savestr,'testErr','tr','net');
            %disp(errorMeasure.testerr);
            % pause();
            %-------------------------------------------------------------
         end
        
        function [GPSout_Ytr,GPSout_x] = retrieveGPSfromSeg(obj,trainSet,Ytr,trainParam)
            
            if isempty(trainSet.in_x)
                GPSout_x.TripInCell = 0;
                GPSout_x.idx = 0;
                GPSout_x.list= 0;
                GPSout_x.GTCell = 0;
                GPSout_Ytr.TripInCell = 0;
                GPSout_Ytr.idx = 0;
                GPSout_Ytr.list = 0;
                return;
            end
            
            windowSize = trainParam.windowSize;
            tar_delay = trainParam.tar_delay;
            attrNum = [3 4]; % GPS attr col
            attrLen = length(attrNum);
            %selectfeat  % get norm info         
            in_x =  cellfun(@(x) x(:,attrNum).*obj.NormInfo.gpsNorm(1),obj.LocalTripCell,'UniformOutput',0);
            
            %extractSeg
            option = 'keep';
            in_x_Seg = cellfun(@(x) extractCellSeg(x,windowSize,tar_delay,option),in_x,'UniformOutput',0); 
            numTrip = length(in_x_Seg);
            start_x = mat2cell(obj.Start,ones(numTrip,1),2);
            
         
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
            Ytr = Ytr'.*obj.NormInfo.gpsNorm; % get norm info
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
             
        
        
        
        
        function obj = setModel(obj,model_in)
            %obj = setModel(model_in,model_parameter)
            %objective: to setup the model
            % input:    model_in (neural network model)
             obj.model = model_in;
        end
            
         function model = getModel(obj)
            %model = getModel(obj)
            %objective: to get the model
            % return model (nntool model)
             model = obj.model;
         end
        
         function obj = setTrainParam(obj,model_parameter)
            %obj = setTrainParam(obj,model_parameter)
            %objective: to set the model parameter
            % input: model_parameter, training parameter
             obj.model_parameter = model_parameter;
         end
        function trainParam = getTrainParam(obj)
            %trainParam = getTrainParam(obj)
            %objective: to get the trainingParameter
            % return trainParam 
             trainParam = obj.model_parameter;
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
            obj = obj.setModel_training_On();
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
            try
                if strcmp(trainParam.useParallel,'yes')
                    pool = parpool;
                    disp(strcat('using parallel computing, # workers : ',int2str(pool.NumWorkers)));
                end
            end
                
            obj = obj.setModel_training_On();
            obj.model_parameter = trainParam;
            [errMeasurement,checkpoint] = goTrainSegKFold(obj,trainParam,errMeasurement,checkpoint);
            
            
            try
                delete(pool);
                disp('stop parallel computing');
            end
        end
        
        function [trPredRe,trSetRe,trainSet,Ytr,obj] = modelPredict(obj)
            
            
            obj = obj.setModel_training_Off();        
            obj.model_parameter.K = obj.model_parameter.KFold+1;
            [trainSet,testSet] = obj.genSegSet(obj.model_parameter);            
            [~,Ytr,testerr] = obj.trainSeg(trainSet,testSet,obj.model_parameter,obj.model);
            [trPredRe,trSetRe] = obj.retrieveGPSfromSeg(trainSet,Ytr,obj.model_parameter);
            
            triperrbin =  (cellfun(@(a,b) (disMethod4(a(:,1),a(:,2),...
                          b(:,1),b(:,2),'naive')).*1000,trSetRe.GTCell,trPredRe.TripInCell,'UniformOutput',0));
            triperr = [trainSet.idx' cell2mat(cellfun(@(a,b) rms(disMethod4(a(:,1),a(:,2),...
                          b(:,1),b(:,2),'naive')),trSetRe.GTCell,trPredRe.TripInCell,'UniformOutput',0)).*1000];
            
            
            
            trPredRe.triperr = array2table(triperr,'VariableName',{'tripIndex','tripRMSError'});
            trPredRe.triperrbin = triperrbin;
            obj.trPredRe = trPredRe;
            obj.trSetRe = trSetRe;
            obj.trainSet =trainSet;
            obj.Ytr =Ytr;
            obj = obj.setModel_training_On();
        end
        
        
        
        function [trPredRe,trSetRe,trainSet,Ytr] = getCheckSet(obj)
            trPredRe = obj.trPredRe;
            trSetRe = obj.trSetRe;
            trainSet = obj.trainSet;
            Ytr = obj.Ytr;
        end
            
            
        function Model_training_status = gettModel_training_status(obj)
            Model_training_status = obj.model_OffTraining;
        end
        
        function  checkPredictError(obj,option,tripID)
            
              goCheckOutput(obj,option,tripID);
            
            
        end
    end
        
    
    methods (Access = private)
        function obj = setModel_training_Off(obj)
            obj.model_OffTraining = 1;
        end
        function obj = setModel_training_On(obj)
            obj.model_OffTraining = 0;
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

