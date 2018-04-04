function goCheckOutput(obj,option,tripIndex)
%% goCheckOutput(obj,option,tripIndex)
% objective: check the result by plotting
% input:     obj: day1TripTrain obj
%            option.zoomRatio; zoomRatio, (0,1] - zoom out,(1,inf) -zoom in
%            option.update;  number of data to update the map
%            option.mapType; mapType specify in plot_google_map, defaults:
%                            'roadmap','satellite', see plot_google_map
%            option.offset;  checking the output by checking the offset val
%            option.timePause; time pause during plotting
%            option.figPos;  fig position
 
idx = 1;
zoomRatio = 1;
update = 20;
mapType='roadmap';
offset = 1;
timePause = 0.05;
figPos = [80 100 1300 600];

if nargin == 3
    idx = tripIndex;
end
try zoomRatio = option.zoomRatio; end
try update = option.update; end
try mapType= option.mapType; end
try offset = option.offset; end
try timePause = option.timePause; end
try figPos = option.figPos; end

[trPredRe,trSetRe,trainSet,Ytr] = obj.getCheckSet(); 
trainParam = obj.getTrainParam;
featDim = 2; %length(trainParam.in_attr);
windowSize = trainParam.windowSize;
current = trSetRe.TripInCell{idx};
gt = trSetRe.GTCell{idx};
pred = trPredRe.TripInCell{idx};
tripLen = length(current(:,1));
tripIndex = trainSet.idx(idx);

current = current(offset:end,:);
gt = gt(offset:end,:);
pred = pred(offset:end,:);


current = current(offset:end,:);
gt = gt(offset:end,:);
pred = pred(offset:end,:);
tripLen = tripLen-offset;
f1 = figure('Name','plot prediction','pos',figPos);
subplot(2,4,[1 2 5 6]);
obj.inspectTrip('TripIndex',tripIndex,'addressOn',1,'getFigOnly','map');
hold off;
subplot(2,4,[3 4 7 8]);
title('current: blue | gt: green | pred: red');
hold on;
hc =[];
hgt = [];
hpr = [];
try
    for i = 1:tripLen
        if i == 1
            for j = 1:windowSize
                hc = [hc plot(current(1,j*2),current(1,j*2-1),'b.')];

                pause(0.1);
            end


            set(hc(end),'Marker','v','MarkerSize',10,'MarkerFaceColor','b');
            axis([gt(1,2)-0.003/zoomRatio gt(1,2)+0.003/zoomRatio gt(1,1)-0.003/zoomRatio gt(1,1)+0.003/zoomRatio]);
                 plot_google_map('MapType','roadmap');
            hgt = plot(gt(1,2),gt(1,1),'g.');
            hpr = plot(pred(1,2),pred(1,1),'r.'); 
        else

            %1. plot current point
            hc = [hc plot(current(i,windowSize*featDim),current(i,windowSize*featDim-1),'b--.')];
            set(hc(end),'Marker','diamond','MarkerSize',10,'MarkerFaceColor','b');
            set(hc(end-1),'Marker','.','MarkerSize',6);
            %2. recolor past points > 
            set(hc(1:i-1),'Marker','.','MarkerSize',6,'Color',[0 0 0]);

            %3. highlight cur segment
            set(hc(i:i+windowSize-2),'Marker','s','MarkerSize',3,'MarkerFaceColor','b');       

            %4. plot gt
            hgt = [hgt plot(gt(i,2),gt(i,1),'g.')];
            set(hgt(end),'Marker','s','MarkerSize',8,'MarkerFaceColor','g');
            set(hgt(end-1),'Marker','.','MarkerSize',6,'MarkerFaceColor','none');
            %5. plot pred
            hpr = [hpr plot(pred(i,2),pred(i,1),'r.')];
            set(hpr(end),'Marker','^','MarkerSize',6,'MarkerFaceColor','r');
            set(hpr(end-1),'Marker','o','MarkerSize',2,'MarkerFaceColor','r');
            
            if ~isempty(timePause)
                pause(timePause);     
            else
                pause();
            end
            
            if mod(i,update/zoomRatio)==0
                axis([gt(i,2)-0.004/zoomRatio gt(i,2)+0.004/zoomRatio gt(i,1)-0.004*0.78/zoomRatio gt(i,1)+0.004*0.78/zoomRatio]);
                plot_google_map('MapType',mapType,'ShowLabels',1,'AutoAxis',0); 


            end
            %}

        end

    end
catch
            delete(f1);
            close all;
end
end