function TripIndex = findIndex(TripInfo,index)
Len = length(index);
TripIndex=zeros(1,Len);
for i=1:Len
TripIndex(1,i) = sum(TripInfo.LengthOfTrip(1:index(i)-1))+1;
end