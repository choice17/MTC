function [lat,lng] = gpsConvert(in_lat,in_lng)
%% gps  [lat,lng] = gpsConvert(in_lat,in_lng)
% take into account that radius of earth is 6378.137 km
% info from http://www.longitudestore.com/how-big-is-one-gps-degree.html
% AT THE EQUATOR
% One degree of latitude =  110.57 km or  68.71 mi
% One minute of latitude =    1.84 km or   1.15 mi
% One second of latitude =   30.72 m  or 100.77 ft
% One degree of longitude = 111.32 km or  69.17 mi
% One minute of longitude =   1.86 km or   1.15 mi
% One second of longitude =  30.92 m  or 101.45 ft
% AT THE POLES
% One degree of latitude =  111.69 km or  69.40 mi
% One minute of latitude =    1.86 km or  1.16 mi
% One second of latitude =   31.03 m  or  101.79 ft
% AT LATITUDE 40 DEGREES (NORTH OR SOUTH)
% One degree of latitude =  111.03 km or  68.99 mi
% One minute of latitude =    1.85 km or 1.15 mi.
% One degree of longitude =  85.39 km or  53.06 mi
% One minute of longitude =   1.42 km or    .88 mi
% One second of longitude =  23.72 m  or  77.82 ft
% AT LATITUDE 80 DEGREES (NORTH OR SOUTH)
% One degree of latitude =  111.66 km or  69.38 mi
% One minute of latitude =    1.86 km or   1.16 mi
% One second of latitude =   31.02 m  or 101.76 ft
% One degree of longitude =  19.39 km or  12.05 mi
% One minute of longitude =    .32 km or    .20 mi
% One second of longitude =   5.39 m  or  17.67 ft
% https://en.wikipedia.org/wiki/Decimal_degrees
% for lng distance calculation [-180 180]
% decimalplaces	decimaldegrees          equator	   E/W:23N/S    E/W:45N/S	E/W:67N/S
%0	1.0         1° 00? 0?       country 111.32 km	102.47 km	78.71 km	43.496 km
%1	0.1         0° 06? 0?       city	11.132 km	10.247 km	7.871 km	4.3496 km
%2	0.01        0° 00? 36?      town	1.1132 km	1.0247 km	787.1 m     434.96 m
%3	0.001       0° 00? 3.6?     street	111.32 m	102.47 m	78.71 m     43.496 m
%4	0.0001      0° 00? 0.36?	land    11.132 m	10.247 m	7.871 m     4.3496 m
%5	0.00001     0° 00? 0.036?	trees	1.1132 m	1.0247 m	787.1 mm	434.96 mm
%6	0.000001	0° 00? 0.0036?	humans	111.32 mm	102.47 mm	78.71 mm	43.496 mm
%7	0.0000001	0° 00? 0.00036?	commer  11.132 mm	10.247 mm	7.871 mm	4.3496 mm
%8	0.00000001	0° 00? 0.000036?mapping	1.1132 mm	1.0247 mm	787.1 µm	434.96 µm
%for lat calculation 
% circumference 40075161.2meters
% one degree of longitude is multiplied by the cosine of the latitude, decreasing the distance, approaching zero at the pole.
% lat is evenly distributed 

%summary for location at around detroit area E/W:45N/S
%lng 0.0001 deci = 7.871 m
%lat 0.0001 deci = 11.132 m


if size(in_lat,2)==1
    DD = fix(in_lat);
    MM = fix(mod(abs(in_lat)*60,60));
    SS = mod(abs(in_lat)*3600,60);
    lat = [DD MM SS];
    
    DD = fix(in_lng);
    MM = fix(mod(abs(in_lng)*60,60));
    SS = mod(abs(in_lng)*3600,60);
    lng = [DD MM SS];
elseif size(in_lat,2)==3
    DD = fix(in_lat(1));
    MMMM = (in_lat(2)*60+in_lat(3))/3600;
    if DD<0
        sign = -1;
    else
        sign = 1;
    end
    lat = (abs(DD)+MMMM)*(sign);
    
    DD = fix(in_lng(1));
    MMMM = (in_lng(2)*60+in_lng(3))/3600;
    if DD<0
        sign = -1;
    else
        sign = 1;
    end
    lng = (abs(DD)+MMMM)*(sign);
end
    


