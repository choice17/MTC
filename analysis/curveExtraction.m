function [trainSet_out,curveRatio,idx] = curveExtraction(trainSet,trainParam)

thistrip.in_x = trainSet.in_x;
thistrip.in_y = trainSet.in_y;


[thistrip.in_x,idx,curveRatio] = cellfun(@(x) tripCurveExtraction(x,trainParam),thistrip.in_x,'UniformOutput',0);
[thistrip.in_y] = cellfun(@(a,b) a(b,:),thistrip.in_y,idx,'UniformOutput',0);
trainSet_out = thistrip;
trainSet_out.idx = trainSet.idx;

end

function [thistrip_in_x,idx,curveRatio] = tripCurveExtraction(thistrip_in_x,trainParam)
windowSize = trainParam.windowSize;
featDim =  length(trainParam.in_attr);
thresh = trainParam.curveRatioThresh;

coord = [thistrip_in_x(:,1:featDim:end) thistrip_in_x(:,2:featDim:end)];
displacement = segDisplacement(coord);
seg_Distance  = segDistance(coord);

curveRatio = displacement./seg_Distance;
idx = curveRatio <= thresh;
thistrip_in_x = thistrip_in_x(idx,:);


end

function displacement = segDisplacement(coord)
displacement = coordDis(coord(:,2),coord(:,1),coord(:,end),coord(:,end-1));
end

function seg_Distance = segDistance(coord)
[segSize,windowSize] = size(coord);
seg_Distance = zeros(segSize,1);
for i = 1:2:windowSize-2
    seg_Distance  = seg_Distance + ...
        coordDis(coord(:,i+1),coord(:,i),coord(:,i+3),coord(:,i+2));
end
end
    


function dis = coordDis(x1,y1,x2,y2)
deltaX = x2-x1;
deltaY = y2-y1;
dis = sqrt(deltaX.^2 + deltaY.^2);
end
