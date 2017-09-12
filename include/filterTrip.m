function [cleanData,delTripID] = filterTrip(day1sec,N)

% read TripID 
TripID = unique(day1sec(:,2),'stable');

temp =[];
delTripID=[];
for i = 1:length(TripID)
 len = length(day1sec(day1sec(:,2)==TripID(i),2));
 if len>N
   temp = [temp; day1sec(day1sec(:,2)==TripID(i),:)];
   else 
 delTripID =  [delTripID;TripID(i)];  
 end
 if mod(i,floor(length(TripID)/100))==0
     fprintf('\t%d percentage filtering\t\n',ceil(i/(length(TripID)/100)));
 end
end
cleanData = temp;
end
