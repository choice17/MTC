clearvars;
addpath ('V2P');
load day1sRe.mat
%load cleanDay1sec.mat;
%[VID TRIPID LAT LONG TIME SPEED]
%[VID TRIPID LAT LONG TIME SPEED normtime]
%% analysis the dataset
%day1sec = day1sRe;
% total VID
VID = unique(day1sec(:,1),'stable');
numVID = length(VID);

% total TripID
TripID = unique(day1sec(:,2),'stable');
numTID = length(TripID);
%{
% TripID per VID
for i = 1:numVID
TpV = unique(day1sec(day1sec(:,1)==VID(i),2));
VIDTrip{i} = TpV;
end
%}

% re look at the dataset 
meant = mean(day1sec(:,[3 4]));
stdt =std(day1sec(:,[3 4]));

% seems some error data here
err= find(abs(day1sec(:,3)-meant(1))>3*stdt(1) | ...
    abs(day1sec(:,4)-meant(2)) > 3*stdt(2)) ;

errID = day1sec(err,[1 2 3 4]);
errTripID = unique(errID(:,2));

goodTrip = TripID~=errTripID';
goodTrip = find(sum(goodTrip,2)==length(errTripID));

goodID = TripID(goodTrip);
%%
% simply take out all trip with data lat=90 long=180
day1sRe=zeros(size(day1sec));
n=1;
L=zeros(size(goodID));
msgl=0;
for i=1:length(goodID)
 trip = day1sec(day1sec(:,2)==goodID(i),:);
 si = size(trip,1);
day1sRe(n:n+si-1,:) = trip;
n = n + si;
L(i) = size(trip,1);
msgl = printper(i,length(goodID),msgl);
end

day1sRe = day1sRe(1:n-1,:);
LengthofTrip = L;
figure(1);
boxplot(LengthofTrip)
xlabel('LengthofTrip')
ylabel('num of Trip')
title('Boxplot for Trip duration')

%% check if the velocity is zero of each trip at the beginning
% ans is no ...
figure(1);
for i =1:5000
index = sum(L(1:i-1))+1:sum(L(1:i)); 
plot(day1sec(index,6));
pause;
end

%% below are the old version
% normalize data 
% crop each trip so that the starting and finishing velocity is 0
% standardize all trip and append the gps to one continuous trip
% store VID TRIPID(w VID) LengthTrip TripStartingPt wholeTrip stdT meanT
option.operate = 'Y';
option.normalizeSize = 100000;
TripInfo = normalizeTripV2(day1sRe,LengthofTrip,option);

%%
%cleanTripInfo,delTripID = filterTripInfo(TripInfo);
%%
%save V2P/cleanDay1sec.mat cleanTripInfo TripInfo delTripID delID
nTrip = [outputs{:}]';
reTrip = recoverTrip(TripInfo,nTrip);

%% Display route
figure(1);
index=1;

for i=1:1:length(TripInfo.TripID(:,2))
    [i TripInfo.CropLen(i)]
    %TripIndex = findIndex(TripInfo,temp(i));
    f=figure(1);
    %plotx = index:index+L;
    plotx = index:index+TripInfo.CropLen(i)-1;
    color = [rand rand rand];
    hold on;
    for j = 1:3:length(plotx)
        
 plot(TripInfo.StandardizeTrip(plotx(j),1),TripInfo.StandardizeTrip(plotx(j),2),'.','Color',color);
    pause(0.005);
    end
    
    index = index+TripInfo.CropLen(i);
    pause(0.01);
    %if mod(i,5)==0
    %close(f);
    %end
    

end
%%  choosing training set

testsize = 1:100000;
Y = TripInfo.StandardizeTrip(testsize',[1 2])';
tar= num2cell(Y,1);
X =  TripInfo.StandardizeTrip(testsize',3)';
input = num2cell(X);

%%  initialize the time-series net
delay = 1;
inputDelays = delay:10+delay-1;
feedbackDelays = delay:10+delay-1;
hiddenLayerSize = [10 10];
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);
net = removedelay(net,delay);
net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';
view(net);
%% config the parameter for training/testing

[inputs,inputStates,layerStates,targets] = ...
    preparets(net,input,{},tar);
 
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio   = 15/100;
net.divideParam.testRatio  = 15/100;
%% training network 
[net,tr] = train(net,inputs,targets,inputStates,layerStates);

%% test on a independent route

% setup input and target of independent route
% where is and ie are the route number Trip ID
    L = TripInfo.CropLen;
    is = 5000; ie = 5050;
    %cal index 
    Ns = sum(L(1:is-1));
    Ne = sum(L(1:ie-1));
    index = Ns:Ne+L(ie)-1;
    %errindex for later use
    errIndex = Ns+9:Ne+L(ie)-1;
    %set inputs parameter for trained net
    thisTrip = TripInfo.StandardizeTrip(index,:)' - ...
        TripInfo.StandardizeTrip(index(1),:)';
    Y = thisTrip([1 2],:);
    tar= num2cell(Y,1);
    X =  thisTrip(3,:);
    input = num2cell(X,1);
   [inputs,inputStates,layerStates,targets] = ...
    preparets(net,input,{},tar);
%% obtain the output (predict by the trained)

outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

%% check the performance 

period=10;
delay=1;
st = 1;
%A=[tar{st:st+period-1}]';
figure(1);
ds = 0.01;
hold on;
%axis([-2E-4 1E-4 0.0128 0.0138]); 
for i=1:1:size(outputs,2)
axis([inputs{2,i}(1)-ds inputs{2,i}(1)+ds ...
    inputs{2,i}(2)-ds inputs{2,i}(2)+ds ]);
% current loc
plot(inputs{2,i}(1),inputs{2,i}(2),'g.','MarkerSize',10);
% ground true loc on (delay)s time 
plot(targets{i}(1),targets{i}(2),'b.','MarkerSize',10);
% pred
plot(outputs{i}(1),outputs{i}(2),'r.','MarkerSize',10);
pause(0.005);
if mod(i,500)==0
 hold off;
 close(figure(1)); hold on;
end
%end

end

%% map to gps value from the predicted value
%  using the normalization information from model TripInfo
reTrip= [outputs{:}]'+TripInfo.StandardizeTrip(index(1),[1 2]);
reTrip = recoverTrip(TripInfo,reTrip);
groundTruth = TripInfo.CropTrip(errIndex,[1 2]);
gpserr = sum(sum((groundTruth-reTrip).^2))/length(reTrip(:,1));


%{


%%
load ph_dataset
inputSeries = phInputs;
targetSeries = phTargets;

inputDelays = 1:4;
feedbackDelays = 1:4;
hiddenLayerSize = 10;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);  
%%
[inputs,inputStates,layerStates,targets] = ...
    preparets(net,inputSeries,{},targetSeries);
view(net)
%%
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio   = 15/100;
net.divideParam.testRatio  = 15/100;

[net,tr] = train(net,inputs,targets,inputStates,layerStates);
%%
outputs = net(inputs,inputStates,layerStates);
errors = gsubtract(targets,outputs);
performance = perform(net,targets,outputs)

view(net)

figure, plotperform(tr)

%%
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
view(netc)
[xc,xic,aic,tc] = preparets(netc,inputSeries,{},targetSeries);
yc = netc(xc,xic,aic);
perfc = perform(netc,tc,yc)

%%
nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
view(nets)
[xs,xis,ais,ts] = preparets(nets,inputSeries,{},targetSeries);
ys = nets(xs,xis,ais);
earlyPredictPerformance = perform(nets,ts,ys)
%%
f=1;
windowS=5;
targetT=1;
delay=1;option=1;
X = []; Y =[];

for i=1:1000
    IN = findIndex(cleanTripInfo,i);
    L = cleanTripInfo.LtengthOfTrip(i);
    trip = cleanTripInfo.StandardizeTrip(IN:IN+L,:);
[x,y] = extractTripIO(trip,windowS,targetT,delay,option);
X=[X x];
Y=[Y y]; 
end
%%
hiddenSizes=[5 5];
trainFcn = 'traingdx';
net=feedforwardnet(hiddenSizes,trainFcn);
net.performParam.regularization = 0.1;
net.layers{1}.transferFcn = 'purelin';
net.layers{2}.transferFcn = 'logsig';

net = configure(net,X,Y([1 2],:));
[net, tr] = train(net, X, Y([1 2],:));
yy=net(X);
%%
figure(2);
for i=1:size(yy,2)
    dd = 15*(i-1);
    xx = [1 4 7 10 13]+dd;
    plot(X(xx),X(xx+1),'g.');
    hold on;
    plot(yy(1,i),yy(2,i),'rx');
    pause(0.5);
end
%% normalize the geometry lat long and velocity
%  afterthat pattern 
%}  



