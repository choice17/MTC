function [errMeasurement,checkpoint] = goTrainKFold(obj,trainParam,errMeasurement,checkpoint)
%% [errMeasurement,checkpoint] = goTrainKFold(obj,trainParam,errMeasurement,checkpoint)
% objective: implement K fold validation training on the parameter
%            time series narxnet implementation
% input:     obj ,day1TripTrainObj
%            trainParam  ,traininParameter
%            errMeasurement ,to log the validation value
%            checkpoint  ,to determine the save option
% output:    checkpoint  , update checkpoint
%            errMeasurement ,update validation log in the iteration
%            errMeasurement =
%            [filename,windowSize,hiddenLayerSize,randomSeed,errorValue,input attrNum]

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


        
