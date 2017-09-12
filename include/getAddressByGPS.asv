function gpsAddress = getAddressByGPS(gpsPoint)
% gpsAddress = getAddressByGPS(gpsPoint)
% input: gpsPoint = [lat lng] %lat and lng should be in coordinate format
% output: gps address in char format
% 2500requests per day per client-side
% if nothing return, 1. request over usage limit per day
%                    2. check the gps input
 
% check for inproporiate gps input
if length(gpsPoint)~=2
    error('not correct gps input');
end

googlegeoapi = 'https://maps.googleapis.com/maps/api/geocode/json?address=';
url =[googlegeoapi num2str(gpsPoint(1),'%.8f') '+' num2str(gpsPoint(2),'%.8f')];
filename = 'getAddressByGPStemp.txt';
urlwrite(url,filename);
fid= fopen(filename);
jsonAddress = textscan(fid,'%s');
fclose(fid);
jsonAddress = jsonAddress{:};
jsonAddress = [jsonAddress{:}];
address =jsondecode(jsonAddress);
if isa(address.results,'cell')
gpsAddress = address.results{1}.formatted_address;
elseif isempty(address.results)
    gpsAddress= 'location not valid';
    display(gpsAddress);
else
    gpsAddress = address.results(1).formatted_address;
end
delete(filename);
end
