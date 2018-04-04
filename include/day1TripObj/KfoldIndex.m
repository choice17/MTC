function [Kfold] = KfoldIndex(tripIndex,K)
% [Kfold] = KfoldIndex(tripIndex,K)
% Objective: divde a set of index in K-fold, K cells
%     input: tripIndex, a set of input index in a vector
%            number of K fold
%    output: Kfold :a set of index stored in K-cells 

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