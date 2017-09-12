function [stdT,meanT,normT] = standardizeTrip(oneTripInfo)
%oneTripInfo should contains M length data
%which columns are [Lat Long Time Speed]
%ouput to normalize[Lat Long Speed Time]           
F = [1 2 4];
T = 3;
%Step I.standardize the trip
tripData = oneTripInfo(:,F);
ntime = oneTripInfo(:,T)./1E6;
ntime = ntime-ntime(1);
meanT = mean(tripData);
stdT = std(tripData);
normT = bsxfun(@rdivide,(tripData-meanT),stdT);

%step II.normalize to zeros at initialization for lat and long
normCoor = bsxfun(@rdivide,normT(:,1:2),normT(1,1:2))-1;
normT = [normCoor normT(:,3) ntime];

end


