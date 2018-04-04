%% ERROR Analysis on errMeasurement on K-fold 
% for segmentation feature extraction
load('errMeasurement_1.mat');
A = errMeasurement(:,2:end-1);
load('errMeasurement_2.mat')
B = errMeasurement(:,2:end-1);
%%
A = [A;B];
sec3err = cell2mat(arrayfun(@(idx) str2num(char(A(:,idx))),1:5,'UniformOutput',0));
%% get the max result for 5 random initialization
x =[];
for k = 2:2:6
    for i = 4:2:12
        for j = 10:5:25       
            idx = find((sec3err(:,1)==k & sec3err(:,2)==i & sec3err(:,3)==j));
            idx = sum(idx.*(idx & (sec3err(idx,5) == max(sec3err(idx,5)))));
            thisrow = sec3err(idx,:);
            x = [x; thisrow];
        end
    end
end
%% 
Modelerr = cell(1,3);
Modelerr = arrayfun(@(idx) sec3err(sec3err(:,1)==idx,:),2:2:6,'UniformOutput',0);
%%

close all;
marker = {'o','s','p','h','+','*','p','h','s'};
%colorR = rand(5,3);
for i = 1:3
   figure(i);
   markeridx=1;
    for windowSize = 4:2:12
            
            %color = RGB(windowSize-1,:);
            hiddenSize = 10:5:25;
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


    title(['Predict ' num2str(i)  's Neural network hidden neuron size to error (m)']);
    xlabel('hidden layer size');
    ylabel('K-fold error(m)');
    hleg = legend('2s','3s','4s','5s','6s');
    htitle = get(hleg,'Title');
    title(htitle,'windowSize')
    hold off;
end





