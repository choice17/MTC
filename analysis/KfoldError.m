function [errorMeter,filename] = KfoldError(net,K,in_x,in_y,day1F_train,trainParam)
% Kfold Error for net
% [errorMeter,filename] = KfoldError(net,K,in_x,in_y,day1F_train,option)
% input: net <- neural net with parameter setup
%        option.netPara <- net parameter 
%        option.netPara.delay <-net delay(predict time)
%        option.netPara.windowSize <-window size
%        in_x <- input (number of trip) by 1 cell type (extra input)
%        in_y <- output (number of trip) by 1 cell type (GPS info)
%        day1F_train <- training obj extracted 100 trip for study
%        K <- number of K-fold
% Output: errorMeter <- record the K time -fold error measure regards to
%                       the training/cv/test set
%         filename <- net and error log saved in the file
%         save <- 0_no save 1_save file 
%

option = trainParam.option;
netPara = option.netPara;
errorMeter=[];

%load random seed1 for trip index
randSeed = loadRandomSeed(1);
rng(randSeed);
tripIndex = randperm(length(day1F_train.TripID));

%tripIndex = [];
tripSize = floor(length(tripIndex)/5);
independentTripIndex = tripIndex(4*tripSize+1:end);
tripIndex = tripIndex(1:4*tripSize);

%K-fold parameter
Kfold =  KfoldIndex(tripIndex,K);
%coloumn one is error by LS-L2, col 2 is gps error
errorset = zeros(K+1,4);
triperr = cell(K+1,1);
independentSet = getTrainTestSet(in_x,in_y,independentTripIndex);
    
for i = 1:K+1
    
    if i<K+1
    %get train/test set index
    [trainSetIndex,testSetIndex] = KfolderIndexOut(Kfold,i);
     
    %get train/test set and config the net
    [trainSet,testSet] = getTrainTestSet(in_x,in_y,trainSetIndex,testSetIndex);
    else
        [trainSet,testSet] = getTrainTestSet(in_x,in_y,tripIndex,independentTripIndex);
    end
    net.divideFcn = trainParam.divideFcn ;
    net.divideParam = trainParam.divideParam;
    [inputs,inputStates,layerStates,targets] = ...
         preparets(net,trainSet.x_mul,{},trainSet.y_mul);
    
     %get initial weight
    
    randSeed = loadRandomSeed(option.randomSeed);
    rng(randSeed);
    net = configure(net,inputs,targets);
    net.iw{3} = net.iw{3}.*0.1;
    net.iw{1} = net.iw{1}.*0.1;
    %training on net
    %net.trainParam.mu = 0.9;
    try 
        if ~isempty(trainParam.epochs)
            net.trainParam.epochs= trainParam.epochs;
        else
            net.trainParam.epochs = 2000-125*(netPara.windowSize-2);
        end
    catch 
         net.trainParam.epochs = 2000-125*(netPara.windowSize-2);
    end
    net.trainParam.showWindow=trainParam.showWindow;
    net.trainParam.max_fail=trainParam.max_fail;
    net.trainParam.min_grad=trainParam.min_grad;
    net.trainParam.goal = trainParam.goal;
    %net.trainParam.mc = 0.7;
    %net.trainParam.lr = 0.1;
    [net,~] = train(net,inputs,targets,inputStates,layerStates);
    
    %load tempnet.mat
    %output the net on test set
    [train_output,~] = net(inputs,inputStates,layerStates);
    [inputs,inputStates,layerStates,test_targets] = ...
         preparets(net,testSet.x_mul,{},testSet.y_mul);
    [test_output,~] =  net(inputs,inputStates,layerStates);
    [inputs,inputStates,layerStates,independent_targets] = ...
         preparets(net,independentSet.x_mul,{},independentSet.y_mul);
    [independent_output,~] =  net(inputs,inputStates,layerStates);
    %save tempnet.mat net
    
    %get errorset
    errorset(i,1) = perform(net,train_output,targets);
    errorset(i,2) = perform(net,test_output,test_targets);
    errorset(i,3) = perform(net,independent_output,independent_targets);
    [errorset(i,4),triperr{i}] = netGPSError(independent_output,day1F_train,netPara,independentTripIndex);
           
end

errorMeter = array2table([[(1:K) 0]' errorset],'VariableNames', ...
    {'K','train_err','cv_err','inde_err','GPS_error'});
filename = ['../model/net-GPS-' datestr(now,'yyyy-mm-dd_HHMMSS') '.mat'];
log.netPara= netPara;
log.Fold = [num2str(K) 'Fold'];
log.weightseed = option.randomSeed;
log.errorMeter = errorMeter;
log.triperr = triperr;
log.time = datestr(now);

if option.save
save(filename,'net','log');
else 
    filename = [];
end
end


function randomSeed = loadRandomSeed(number)
filename = ['../include/randomSeed/randomSeed' num2str(number) '.mat'];
load(filename);
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
        
function [trainSetIndex,testSetIndex] = KfolderIndexOut(Kfold,number)
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

function [trainSet,testSet] = getTrainTestSet(in_x,in_y,trainSetIndex,testSetIndex)

% for trainning set
numTrip = length(trainSetIndex);
in_y_str=['in_y{' num2str(trainSetIndex(1)) '}'];
in_x_Str =['in_x{' num2str(trainSetIndex(1)) '}'];
    for i=2:numTrip        
    in_y_str = strcat(in_y_str,',','in_y{',num2str(trainSetIndex(i)),'}');
    in_x_Str = strcat(in_x_Str,',','in_x{',num2str(trainSetIndex(i)),'}');
    end
    funchar= char(strcat('y_mul=catsamples(',in_y_str,',''pad'');'));   
    eval(funchar);
    funchar= char(strcat('x_mul=catsamples(',in_x_Str,',''pad'');'));  
    eval(funchar);
trainSet.y_mul = y_mul;
trainSet.x_mul = x_mul;

if nargin == 4
%for testing set
numTrip = length(testSetIndex);
in_y_str=['in_y{' num2str(testSetIndex(1)) '}'];
in_x_Str =['in_x{' num2str(testSetIndex(1)) '}'];
    for i=2:numTrip        
    in_y_str = strcat(in_y_str,',','in_y{',num2str(testSetIndex(i)),'}');
    in_x_Str = strcat(in_x_Str,',','in_x{',num2str(testSetIndex(i)),'}');
    end
    funchar= char(strcat('y_mul=catsamples(',in_y_str,',''pad'');'));   
    eval(funchar);
    funchar= char(strcat('x_mul=catsamples(',in_x_Str,',''pad'');'));  
    eval(funchar);
testSet.y_mul = y_mul;
testSet.x_mul = x_mul;
else 
    testSet =[];
end
    
    




end

function [errorGPS,gpserrMean] = netGPSError(test_output,day1F_train,netPara,testSetIndex)
    windowSize = netPara.windowSize;
    delay = netPara.delay;
    %% error measure
    reTrip = tripCellDim(test_output);
    tarIndex = windowSize+delay;
    %Recover from normalized value GPSV2 KfoldV2
    teststart = day1F_train.Start(testSetIndex,:);
    %teststart = [ 42.3053253 -83.6694169]; %ann arbor
    numTrip = size(reTrip,1);
    groundTruth =cell(numTrip,1);
    current = cell(numTrip,1);
    gpserrMean = zeros(numTrip,2);
    %0.1 refer to normalize parameter in day1_trainObj
    for i = 1:numTrip
    
        if strcmp(day1F_train.GPSMode,'UTM')
             %cover from normalized value
            reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},day1F_train.TripSTD),teststart(i,:));
            %reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},[0.1]),teststart);
            reTrip{i} = utm2ll(reTrip{i}(~isnan(reTrip{i}(:,1)),2), ...
                reTrip{i}(~isnan(reTrip{i}(:,1)),1),day1F_train.TripZone{i});
            %get groundTruth
            groundTruth{i} = day1F_train.TripInCell{testSetIndex(i)}(tarIndex:end,[3 4]);
            current{i} = day1F_train.TripInCell{testSetIndex(i)}(windowSize:end-delay,[3 4]);
        else    
        %cover from normalized value
        reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},day1F_train.TripSTD(1,:)),teststart(i,:));
        %reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},[0.1]),teststart);
        reTrip{i} = reTrip{i}(~isnan(reTrip{i}(:,1)),:);
        %get groundTruth
        groundTruth{i} = day1F_train.TripInCell{testSetIndex(i)}(tarIndex:end,[3 4]);
        current{i} = day1F_train.TripInCell{testSetIndex(i)}(windowSize:end-delay,[3 4]);
        end
    %gps distance method
    gpserr = (disMethod4(groundTruth{i}(:,1),groundTruth{i}(:,2), ...
        reTrip{i}(1:end-delay,1),reTrip{i}(1:end-delay,2),'naive'))*1000;
    %gpserr = distance(groundTruth{i}(:,1),groundTruth{i}(:,2), ...
    %    reTrip{i}(1:end-delay,1),reTrip{i}(1:end-delay,2),E);
    
    
    %gpserr = sqrt(sum((groundTruth-reTrip).^2,2));
    gpserrMean(i,:) = [testSetIndex(i) rms(gpserr)];   
    
    
    end
    
    errorGPS = mean(gpserrMean(:,2));
        
end
    


   






