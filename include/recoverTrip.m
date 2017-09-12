function reTrip = recoverTrip(TripInfo,nTrip)

stdT = TripInfo.NormalizeInfo(1,1:2);
meanT = TripInfo.NormalizeInfo(1,4:5);
normTstpt = TripInfo.NormalizeInfo(1,7:8);

reTrip = nTrip + normTstpt;
reTrip = reTrip.*stdT + meanT;
end