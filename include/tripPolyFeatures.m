 function TripInfo = tripPolyFeatures(TripInfo1FHz)
 % TripInfo1FHz = tripPolyFeatures(TripInfo1FHz)
 % output poly features trip information
 % select parameter here
 % standarize: standard = 1 | centered trip: standard =0
 % poly multivariant p degree 
 % cross multiply the feature 
 % featCol for multi degree feature
 
 standard = 0;
 p = 3 ; 
 cross = true;
 featCol = [1 2 9];
 
 
 % retrieve the trip in mat
 fprintf('getting the info from the dataset...\n');
 if standard
 thisTrip = [TripInfo1FHz.StandardizeTripCell{:}]';
 else 
     thisTrip = [TripInfo1FHz.CenteredTripCell{:}]';
     thisTrip = [thisTrip{:}]';
 end
  M = size(TripInfo1FHz.StandardizeTripCell,1);
  numPoint = size(thisTrip,1);
  
 % retrieve the value from normalize value
 % from centered trip
 fprintf('recover the value from normalized data...\n');
 
 reTrip = thisTrip.*TripInfo1FHz.CenteredNormalizeInfo(1,1:11);
 
 fprintf('adding higher degree of the features into data...\n');
 tripPFeatures = polyFeatures(reTrip(:,featCol),p,cross);
 
 % testing poly feature column taken
 reTrip = [reTrip tripPFeatures(:,[end-6:end])];
 TripInfo1FHz.CenteredNormalizeInfo = std(reTrip);
 reTrip = [thisTrip ...
     tripPFeatures(:,[end-6:end])./TripInfo1FHz.CenteredNormalizeInfo(1,[end-6:end])];
 tripBegin = 1;
 msgl=0;
 
 for i=1:M     
    index = tripBegin:tripBegin+TripInfo1FHz.LengthOfTrip(i)-1;
    MeanTrip(i,:) = mean(reTrip(index,:));
    reTrip(index,:) = reTrip(index,:) -  MeanTrip(i,:);
    TripInfo1FHz.CenteredTripCell{i} = num2cell(reTrip(index,:)',1);    
    tripBegin = tripBegin + TripInfo1FHz.LengthOfTrip(i);
    msgl = printper(i,M,msgl);
 end
 TripInfo = TripInfo1FHz;
 TripInfo.MeanTrip = MeanTrip;
 
 
     