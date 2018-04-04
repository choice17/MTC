function day1_obj = goRemoveTrip(day1_obj,operation,index)
% day1_obj = goRemoveTrip(day1_obj,operation,index)
% Objective: to remove unwanted trips data in day1_obj
% inputs   : day1_obj, day1TripTrain obj 
%          : operation, operation mode, 'keep' - keep the trip data specify
%                                                in the index input
%          : index, trip index related to operation mode
% output   : day1_obj, updated day1TripTrain obj with removed trips

tripObj = day1_obj;
if strcmp(operation,'keep')
    %retrieve one trip
    TripID = tripObj.TripID(index);
    TripLen = tripObj.TripLen(index);
    TripAttr = tripObj.TripAttr;
    Log = tripObj.Log;
    numTrip = length(index);
    TripInCell = cell(numTrip,1);
    TripInfo = zeros(sum(TripLen),size(tripObj.TripInfo,2));
    
    tripIndex = 1;
    for i = 1:numTrip
       tripInfoIndex = tripIndex:tripIndex+TripLen(i)-1;
       TripInCell{i} =  tripObj.TripInCell{index(i)};
       TripInfo(tripInfoIndex,:) = tripObj.TripInCell{index(i)};
       tripIndex = tripIndex+TripLen(i);
    end
       
    Log = [Log; ['keep only ' num2str(numTrip,'%i') ' trips. Done at ' datestr(now)]];    
    day1_obj.TripID =  TripID;
    day1_obj.TripInfo = TripInfo;
    day1_obj.TripInCell = TripInCell;
    day1_obj.TripLen = TripLen;
    day1_obj.TripAttr = TripAttr;
    day1_obj.Log = Log;
    
elseif strcmp(operation,'delete')
    % not done yet

end
