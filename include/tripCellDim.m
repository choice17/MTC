function  [test_cell,test_mat] = tripCellDim(test_output)
%output is the mat from test_out
%original cell dimension { 2 X tripNum X tripduration }
%output cell dimension {2 X tripduration X tripNum }
[columnIndex] = length(test_output);
[rowIndex,numTrip] = size(test_output{1});
test_mat= permute(reshape(cell2mat(test_output(:)), rowIndex,columnIndex,numTrip), ...
    [2 1 3]);
test_cell = squeeze(mat2cell(test_mat,columnIndex,rowIndex,ones(1,numTrip)));
end

