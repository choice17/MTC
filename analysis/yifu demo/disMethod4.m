function dist = disMethod4(lat1,lng1,lat2,lng2,option)
% distance = disMethod4(lat1,lon1,lat2,lon2)
% Objective: to find the distance between two gps location
% Input:  GPS location of point1 lat1,lng1
%         GPS location of point2 lat2,lng2
% output: distance (km)
% Note:____________________________________________________
% GPS value transfer from degree,mintues,second
% lat lng can be a N by 1 vector of gps value
% and size of lat1 lng1 must be matched to lat2 and lng2
% distance in km based on Pythagoras’ theorem
% (see: http://en.wikipedia.org/wiki/Pythagorean_theorem)
% After:
% http://www.movable-type.co.uk/scripts/latlong.html
% Please try distance()
% meter = distance(lat1,lng1,lat2,lng2,referenceObj);
% referenceObj = referenceEllipsoid('wgs84');
% referenceObj = referenceSphere('earth');

if nargin == 4
    option = 'matlab';
end

if strcmp(option,'matlab')
    eplObj = referenceEllipsoid('wgs84');
    dist = distance(lat1,lng1,lat2,lng2,eplObj)./1000;
else
    delta_lat=111.3237.*(lat2-lat1);
    delta_lng=111.1350.*(lng2-lng1).*cos((lat2+lat1).*pi/360);
    dist=sqrt(delta_lat.^2+delta_lng.^2);
end   
    
end