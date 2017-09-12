function outTrip = extractTripByID(day1_fullSec,TripID)

msgl=0;
n=1;

for i=1:length(TripID)
    trip =  day1_fullSec(day1_fullSec(:,2)==TripID(i),:);
    si = size(trip,1);
    %filter trip less 30s
    if si>=1
    outTrip(n:n+si-1,:) = trip;
    n = n + si;
    L(i) = si;
    else 
        L(i) = 0;
    end    
    msgl = printper(i,length(TripID),msgl);
end
