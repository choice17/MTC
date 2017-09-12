%% testing - map to higher variance 
% let try to make it multi variance

clearvars;close all;
% reload the file
load V2P/day1sRe.mat
load V2P/TripInfo.mat
%load V2P/prednet.mat

%% time series network design
% 2 sample delay (2s)
% use 5 samples as input
delay = 3;
sampleSize = 5;
inputDelays = delay:sampleSize+delay-1;
feedbackDelays = delay:sampleSize+delay-1;
hiddenLayerSize = 2;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

net = removedelay(net,delay);
net.trainFcn = 'trainlm';

%net.layers{1}.transferFcn = '';
net.layers{1}.transferFcn = 'logsig';
view(net);

%% data selection
% poly power feature normalize data 

P=3;
F = size(TripInfo.CropTrip,2);
cropTrip = TripInfo.CropTrip;
%ctP3 = cropTrip(:);
%ctP3 = cropTrip;
%ctP3 = cell2mat(currenttrip)';
ctP3 = polyFeatures(cropTrip,P,true);

% multi variance seems do not improve the result

%% select training sample and normalize
    L = TripInfo.CropLen;
    is = 301; ie =1300;
    %cal index 
    
    Ns = sum(L(1:is-1));
    Ne = sum(L(1:ie-1));
    index = Ns:Ne+L(ie)-1;
    %errindex for later use
    errIndex = Ns+sampleSize+delay-1:Ne+L(ie)-1;
    %set inputs parameter for trained net
    thisTrip = ctP3(index,:);
        %ctP3(index(1),:)';
    normInfo.meanNT = mean(thisTrip);
    %normInfo.stdNT = std(thisTrip);
    
    normNT = ((thisTrip-normInfo.meanNT)./normInfo.stdNT)';
    normInfo.startPt = normNT(:,1)';
    normNT = normNT ;%- normInfo.startPt(:,1);
    % time series feature selection 
    Y = [normNT([1 2],:) ];%;(1:length(normNT(1,:)))];
    tar= num2cell(Y,1);
    in_feature = [4 5 7 8 10 11 12];
    X =  normNT(in_feature,:);
    input = num2cell(X,1);
    clear X Y ;
    %% config network parameters   

    [inputs,inputStates,layerStates,targets] = ...
        preparets(net,input,{},tar);
 
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio   = 15/100;
    net.divideParam.testRatio  = 15/100;

    %% training network 
    [net,tr] = train(net,inputs,targets,inputStates,layerStates);
    
    %% getting the outputs
    outputs = net(inputs,inputStates,layerStates);
    errors = gsubtract(targets,outputs);
    performance = perform(net,targets,outputs)
    
    %% error measure
    reTrip = [outputs{1:end-delay}]';
    gt = [targets{1:end-delay}]';
    reTrip = reTrip.*normInfo.stdNT(1,[1 2]) + normInfo.meanNT(1,[1 2]);
    gt = gt.*normInfo.stdNT(1,[1 2]) + normInfo.meanNT(1,[1 2]);
    
    groundTruth = ctP3(errIndex,[1 2]);
    gpserr = sqrt(sum((groundTruth-reTrip).^2,2));
    gpserr = rms(gpserr)
    %% tranfer to gps
    current = [inputs{2,:}]'.*normInfo.stdNT(1,[1 2]) + normInfo.meanNT(1,[1 2]);
    pred = [outputs{1:end-delay}]'.*normInfo.stdNT(1,[1 2]) + normInfo.meanNT(1,[1 2]);
    gt = [targets{:}]'.*normInfo.stdNT(1,[1 2]) + normInfo.meanNT(1,[1 2]);
    %current = num2cell(current,2);
    %    pred = num2cell(pred,2);
    %        gt = num2cell(gt,2);

    
    
    %% display check performance
     close;
    addpath('yifudelivery');
    option.plotnum = 1;
    option.startPos = 2;
    option.cursorwidth = 0.002;
    option.fignum =1 ; 
    option.time =0.02;
    option.refresh = true; 
    option.refreshTime = 100;
    option.gps = 1;
    option.pause = 0;
    option.repeat=0;
    option.gooMap ='satellite';
    option.zoom=1.5;
    option.label=0;
    option.line=1;
    
   fignum =  figure(1);
   plot(1,1);
  set(gca,'Color',[0 0 0]);
    hold on;
    
    plotPredictRoute(current,pred,gt,option);
    
    
    
  
    
    
%% look at what the neural network got

n1h = reshape(reshape(net.IW{1,1}',[],1),length(in_feature),[]);

n1a = net.IW{1,2}';
