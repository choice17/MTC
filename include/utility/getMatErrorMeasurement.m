function errMat = getMatErrorMeasurement(errMeasurement)

numModel = length(errMeasurement(:,1));

modelName = errMeasurement(:,1);
modelParameterErr = reshape(str2num(char(errMeasurement(:,2:6))),numModel,[]);
modelInput = str2num(char(errMeasurement(:,7)));


errMat.modelName= modelName;
errMat.modelParameterErr = modelParameterErr;
errMat.modelInput = modelInput;

end
%%
function thisSort(errPlot) 
[~,index] = sort(errPlot.modelParameterErr(:,2));
terrPlot.modelParameterErr = errPlot.modelParameterErr(index,:);
terrPlot.modelName = errPlot.modelName(index);
[~,index] = sort(terrPlot.modelParameterErr(:,1));
terrPlot.modelParameterErr = terrPlot.modelParameterErr(index,:);
terrPlot.modelName = terrPlot.modelName(index);
errPlot = terrPlot;
end

