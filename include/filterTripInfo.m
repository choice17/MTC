function [NewInfo,delTripID] = filterTripInfo(TripInfo)

%filter trip with problem value
problemTrip = find(TripInfo.NormalizeInfo(:,1)>1 | ...
                   TripInfo.NormalizeInfo(:,2)>1);
delTripID = TripInfo.TripID(problemTrip);

filterTrip = find(TripInfo.NormalizeInfo(:,1)<1 & ...
                   TripInfo.NormalizeInfo(:,2)<1);
TripIndex = findIndex(TripInfo,filterTrip);

NewInfo.TripID = TripInfo.TripID(filterTrip);
NewInfo.LengthOfTrip = TripInfo.LengthOfTrip(filterTrip);
NewInfo.StartPoint = TripInfo.StartPoint(filterTrip,:);
NewInfo.NormalizeInfo = TripInfo.NormalizeInfo(filterTrip,:);

totalLen = sum(NewInfo.LengthOfTrip);
NewInfo.StandardizeTrip = zeros(totalLen, ... 
    length(TripInfo.StandardizeTrip(1,:)));

index=1;
L=length(TripIndex);
fprintf('\tfiltering ... \n');
for i=1:L
    
    NewInfo.StandardizeTrip(index:index+NewInfo.LengthOfTrip-1,:)= ...
        TripInfo.StandardizeTrip(TripIndex:TripIndex+NewInfo.LengthOfTrip-1,:);
    index=index+NewInfo.LengthOfTrip;
    
    if mod(i,floor(L/100))==0
       fprintf('\t%d percent\t\r',i/floor(L/100));
    end
end

