function [errorMeter,filename] = segKfoldError(net,day1_Obj,trainParam)
% Kfold Error for net
% [errorMeter,filename] = KfoldError(net,K,in_x,in_y,day1_train,option)
% input: net <- neural net with parameter setup
%        option.netPara <- net parameter 
%        option.netPara.delay <-net delay(predict time)
%        option.netPara.windowSize <-window size
%        day1_train <- training obj extracted 100 trip for study
%        KFold <- number of K-fold
% Output: errorMeter <- record the K time -fold error measure regards to
%                       the training/cv/test set
%         filename <- net and error log saved in the file
%         save <- 0_no save 1_save file 
%
day1_train = day1_Obj;

KFold = trainParam.KFold;
option = trainParam.option;
netPara = option.netPara;
errorMeter=[];


%load random seed1 for trip index
randSeed = loadRandomSeed(1);
rng(randSeed);
tripIndex = randperm(length(day1_train.TripID));

%tripIndex = [];
%tripSize = floor(length(tripIndex)/5);
%independentTripIndex = tripIndex(4*tripSize+1:end);
%tripIndex = tripIndex(1:4*tripSize);

%K-fold parameter
KFoldIdx =  KfoldIndex(tripIndex,KFold);
%coloumn one is error by LS-L2, col 2 is gps error
errorset = zeros(KFold,2);
triperr = cell(KFold,1);
    
for i = 1:KFold+1
    trainParam.K = i;
    %extract the segment
    [trainSet,testSet] = day1_train.genSegSet(trainParam);
    
    %train the model using segment feature
    [testY,trainY,errMeasure,net] = day1_train.trainSeg(trainSet,testSet,trainParam,net);
    
    %retrieve the GPS from segment feature
    [trPredRe,trSetRe] = day1_train.retrieveGPSfromSeg(trainSet,trainY,trainParam);
    [tPredRe,tSetRe] = day1_train.retrieveGPSfromSeg(testSet,testY,trainParam);
    
    %save the error measurement respective to distance(m)
    errorset(i,1) = errMeasure.trainerr;
    errorset(i,2) = errMeasure.testerr;
    
    if i<=KFold 
    triperr{i} = [testSet.idx' cell2mat(cellfun(@(a,b) rms(disMethod4(a(:,1),a(:,2),...
        b(:,1),b(:,2),'naive')),tSetRe.GTCell,tPredRe.TripInCell,'UniformOutput',0)).*1000];
    end
        
end

errorMeter = array2table([[(1:KFold+1)]' errorset],'VariableNames', ...
    {'K','train_err','cv_err'});
filename = ['../model/net-GPS-' datestr(now,'yyyy-mm-dd_HHMMSS') '.mat'];
log.netPara= netPara;
log.Fold = [num2str(KFold) 'Fold'];
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

function [errorGPS,gpserrMean] = netGPSError(test_output,day1_train,netPara,testSetIndex)
    windowSize = netPara.windowSize;
    delay = netPara.delay;
    %% error measure
    reTrip = tripCellDim(test_output);
    tarIndex = windowSize+delay;
    %Recover from normalized value GPSV2 KfoldV2
    teststart = day1_train.Start(testSetIndex,:);
    %teststart = [ 42.3053253 -83.6694169]; %ann arbor
    numTrip = size(reTrip,1);
    groundTruth =cell(numTrip,1);
    current = cell(numTrip,1);
    gpserrMean = zeros(numTrip,2);
    %0.1 refer to normalize parameter in day1_trainObj
    for i = 1:numTrip
    
        if strcmp(day1_train.GPSMode,'UTM')
             %cover from normalized value
            reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},day1_train.TripSTD),teststart(i,:));
            %reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},[0.1]),teststart);
            reTrip{i} = utm2ll(reTrip{i}(~isnan(reTrip{i}(:,1)),2), ...
                reTrip{i}(~isnan(reTrip{i}(:,1)),1),day1_train.TripZone{i});
            %get groundTruth
            groundTruth{i} = day1_train.TripInCell{testSetIndex(i)}(tarIndex:end,[3 4]);
            current{i} = day1_train.TripInCell{testSetIndex(i)}(windowSize:end-delay,[3 4]);
        else    
        %cover from normalized value
        reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},day1_train.TripSTD(1,:)),teststart(i,:));
        %reTrip{i} = bsxfun(@plus,bsxfun(@times,reTrip{i},[0.1]),teststart);
        reTrip{i} = reTrip{i}(~isnan(reTrip{i}(:,1)),:);
        %get groundTruth
        groundTruth{i} = day1_train.TripInCell{testSetIndex(i)}(tarIndex:end,[3 4]);
        current{i} = day1_train.TripInCell{testSetIndex(i)}(windowSize:end-delay,[3 4]);
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
    


   






