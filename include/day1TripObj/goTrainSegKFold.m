function [errMeasurement,checkpoint] = goTrainSegKFold(obj,trainParam,errMeasurement,checkpoint)
%% function [errMeasurement,checkpoint] = goTrainSegKFold(obj,trainParam,errMeasurement,checkpoint)
% Objective: training with K -fold validation with segmentation feature
% extraction, includes in training section of goTrainSegKFold in day1TripTrain
%     input: obj - day1TripTrain  Obj
%            trainParam - training parameter of the feedforward network
%            errMeasurement - error log of the training
%            checkpoint - current checkpoint
%    output: errMeasurement - updated error log of the training 
%            checkpoint - update checkpoint


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
            net.divideFcn = trainParam.divideFcn;
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
    
            
        
        