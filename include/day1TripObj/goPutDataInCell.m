function  day1_obj = goPutDataInCell(day1_full,attr)
% day1_obj = goPutDataInCell(day1_full,attr)
% Objective: I.   sort trip by trip duration ascending order
%            II.  re-label duplicate trip
%            III. put the trips data in obj.
% input: raw dataset :day1_full matrix from day1_full.mat
%        attr        :default value illustrated as below
% output: day1_obj (day1TripTrain obj)         

if nargin == 1 || isempty(attr)
attr.featCol = [ 1 2 8 9 10 11 12 13 14 15 16 18 19 4 ];
attr.Name = {'VID' 'TripID' 'Lat' 'Long' 'Elevation' ...
        'Speed' 'Heading' 'Ax' 'Ay' 'Az' 'Yawrate' ... 
        'RadiusOfCurve' 'Confidence' 'Time'};
elseif length(attr.featCol) ~= length(attr.featCol)
    error('attr name and number feature column are not balanced');
end
    


%total TripID
day1_full = day1_full(:,attr.featCol);
[TripID,~,position] = unique(day1_full(:,2),'stable');
N = length(TripID);
posindex = [1:length(position)]';
uniqueTrip = [];
msgl=0;

fprintf('checking if there is duplicate tripID...\n');
for i = 1:N
  
    index = position==i;
    checktrip = find(diff(posindex(index))~=1);
    thistrip = day1_full(index,:); 
    thistrip2 =[];
    
    if ~isempty(checktrip)
        %check if there is duplicate tripID
        %and rename the duplicate tripID
        fprintf('find one duplicate tripID: %i\n',TripID(i));
        fprintf('rename the duplicate tripID as : %i\n',TripID(i)*1000);
           
        thistrip2 = thistrip(checktrip:end,:);
        thistrip2(:,2) = thistrip2(:,2).*1000;
        thistrip = thistrip(1:checktrip-1,:); 
    end
    
    uniqueTrip = [uniqueTrip;thistrip;thistrip2];
    msgl=printper(i,N,msgl);
end

fprintf('finish checking duplicate ID\n');
%load uniqueTrip.mat
[TripID,tripIDIndex] = unique(uniqueTrip(:,2),'stable');

%trip duration 
tripLen = [diff(tripIDIndex)' length(uniqueTrip(:,1))-tripIDIndex(end)+1];
 
%sort the trip in ascending order
featLen = length(attr.featCol);
[tripLenAscend,tripIndex] = sort(tripLen,'ascend');
tripDuration = [TripID(tripIndex) tripLenAscend'];
day1AscTripDuration = zeros(length(uniqueTrip(:,1)),featLen);
tripAscend = cell(length(tripIndex(1,:)),1);
j=1;msgl = 0;N = length(tripIndex);

fprintf('start rearranging the trip by ascending trip duration\n');
for i =1:N
    thistrip = uniqueTrip(uniqueTrip(:,2)==tripDuration(i,1),:);

    day1AscTripDuration(j:j+tripDuration(i,2)-1,:)=thistrip;
    tripAscend{i} = thistrip;

    j = j + tripDuration(i,2);
    msgl = printper(i ,N,msgl);
end

day1_obj =[]; 

day1_obj.TripInfo = day1AscTripDuration;
day1_obj.TripInCell = tripAscend;
day1_obj.TripID = tripDuration(:,1);
day1_obj.TripLen = tripDuration(:,2);
day1_obj.TripAttr = attr.Name;
end