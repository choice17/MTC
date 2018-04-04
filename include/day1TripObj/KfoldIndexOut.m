function [trainSetIndex,testSetIndex] = KfoldIndexOut(Kfold,number)
% [trainSetIndex,testSetIndex] = KfoldIndexOut(Kfold,number)
% Objective: K-fold validation utility, given K-fold cell index, and
% extract the trainSet index and test set index with the iternation number
% Input:     Kfold, a set of index stored in K-cells
%            number, number of current K-fold iteration
% Output:    trainSetIndex, stack of trainset index
%            testSetIndex, stack of testset index

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
