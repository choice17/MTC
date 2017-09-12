%% ERROR Analysis on errMeasurement on K-fold 
% load segment for segmentation feature extraction
load('errMeasurement-24_05s.mat');
A = errMeasurement(:,1:end-1);
%A = errMeasurement;
load('errMeasurement-6_05s.mat')
B = errMeasurement(:,1:end-1);
%A = [A;errMeasurement];
%% 
A = [A;B];
sec3err = cell2mat(arrayfun(@(idx) str2num(char(A(:,idx))),1:5,'UniformOutput',0));
%% get the max result for 5 random initialization
%
%x =[];
%for k = 2:2:4
%    for i = 10:10
%        for j = 5:5:40
%            idx = find((sec3err(:,1)==k & sec3err(:,2)==i & sec3err(:,3)==j));
%            idx = sum(idx.*(idx & (sec3err(idx,5) == max(sec3err(idx,5)))));
%            thisrow = sec3err(idx,:);
%            x = [x; thisrow];
%        end
%    end
%end

%% to get the numerical result and store in Modelerr
Modelerr = cell(1,3);
Modelerr = arrayfun(@(idx) sec3err(sec3err(:,1)==idx,:),2:2:6,'UniformOutput',0);
%% plot graph regards to error measurement in Modelerr

close all;
marker = {'o','s','p','h','+','*','p','h','s'};
%colorR = rand(5,3);
for i = 1:3
   figure(i);
   markeridx=1;
    for windowSize = 10:10
            
            %color = RGB(windowSize-1,:);
            hiddenSize = 5:5:40;
            randomSeed = 5;
            index = Modelerr{i}(:,2)==windowSize;
            ploterror = min(reshape(Modelerr{i}(index,5),randomSeed,[]));
            modelPlot = plot(hiddenSize,ploterror, ...
                [marker{markeridx} '--'],'MarkerSize',5, ...
                'LineWidth',1);%'Color',color);
              set(modelPlot, 'MarkerFaceColor', get(modelPlot, 'Color'));
            %[i windowSize find(ModelError{i}(index,5) == min(ModelError{i}(index,5))) min(ModelError{i}(index,5))]
            hold on;
            markeridx = markeridx +1;
            %[i windowSize]
            pause();
    end


    title(['Predict t+' num2str(i)  's (ws=5s, ''speed'') Neural network hidden neuron size to error (m)']);
    xlabel('hidden layer size');
    ylabel('K-fold error(m)');
    %hleg = legend('ws-5s','3s','4s','5s','6s');
    %htitle = get(hleg,'Title');
    %title(htitle,'windowSize')
    hold off;
end





