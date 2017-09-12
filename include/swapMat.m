function mat_out = swapMat(mat_in,direction,V1,V2)
% mat_out = swapMat(mat_in,direction,V1,V2)
% swap Matrix col or row refer to val V1 and V2
% input: number of col/row to swap :V1 and V2
%        direction: 'C' or 'R'
%        matrix input 
mat = mat_in;
if strcmp(direction,'C')
    tempV2 = mat_in(:,V2);
    mat(:,V2)=mat(:,V1);
    mat(:,V1)=tempV2;
elseif strcmp(direction,'R')
    tempV2 = mat_in(V2,:);
    mat(V2,:)=mat(V1,:);
    mat(V1,:)=tempV2;
end
mat_out = mat;