function [index,gpsAddress,meanspeed] = inspectTripAttr(day1F_Re,option,ID,vargin)
% index = inspectTripAttr(option,ID,day1F_Re,dataNum,addressOn)
% to plot the information of the attribute and map for inspection
% input:    option: 'TripID'/'TripIndex' 
%           ID: either index of the trip in day1F_Re or tripID number
%           day1F_Re rearrange the trip day1_fullSec
%           dataNum: integer so that to inspect specific point in map
%           addressOn: to show the address of the trip
%           getFigOnly: 'all'/'map'/'feat'

varLen = length(vargin);
dataNum = [];
addressOn = 0;
mapType = [];
getFigOnly = 'all';

for i = 1:2:varLen
    switch vargin{i}
        case 'dataNum'
            dataNum = vargin{i+1};
        case 'addressOn'
            addressOn = vargin{i+1};
        case 'mapType'
            mapType = vargin{i+1};
        case 'getFigOnly'
            getFigOnly = vargin{i+1};
    end
end



if strcmp(option,'TripID')
    index = find(day1F_Re.TripID==ID);
elseif strcmp(option,'TripIndex')
    index = ID;
else 
    fprintf('not valid option\n');
end

tripID = day1F_Re.TripID(index);
gpsAddress = [];


%plot google map
thisTrip = day1F_Re.TripInCell{index};

switch getFigOnly
    case 'all'
        fPlotMap = figure('Name','Plot data');
        plot(thisTrip(:,4),thisTrip(:,3),'b.','MarkerSize',8);
        hold on;
        plot(thisTrip([1 end],4),thisTrip([1 end],3),'rx','MarkerSize',10);
        stxt = text(thisTrip(1,4),thisTrip(1,3),'Start','Color','red','FontSize',12);
        etxt = text(thisTrip(end,4),thisTrip(end,3),'End','Color','red','FontSize',12);
        if addressOn == 1
            gpsAddress = getAddressByGPS(thisTrip(1,[3 4]));

        end    
        tripLen = day1F_Re.TripLen(index);
        for i = 1:floor(tripLen/50):tripLen
        text(thisTrip(i,4),thisTrip(i,3),num2str(i,'%i'),'Color','black','FontSize',8);
        end
        if ~isempty(dataNum)
          dtxt = text(thisTrip(dataNum,4),thisTrip(dataNum,3),num2str(dataNum,'%i'),'Color','red','FontSize',24);
        end
        hold off;

        if isempty(mapType) 
        plot_google_map;
        else 
            plot_google_map('MapType',mapType);
        end
        title({sprintf('TripID: %5i',tripID),gpsAddress});

        fPlotFeat = figure('Name','Plot data feature');
        subplot 241;
        plot(thisTrip(:,5)); ylabel('Elevation (m)');
        subplot 242;
        plot(thisTrip(:,6)); ylabel('Speed (m/s)');
        meanspeed =mean(thisTrip(:,6));
        subplot 243;
        plot(thisTrip(:,7)); ylabel('Heading (deg)');
        subplot 244;
        plot(thisTrip(:,8)); ylabel('Ax (m/s^2)');
        subplot 245;
        plot(thisTrip(:,9)); ylabel('Ay (m/s^2)');
        subplot 246;
        plot(thisTrip(:,10)); ylabel('Az (m/s^2)');
        subplot 247;
        plot(thisTrip(:,11)); ylabel('Yawrate (deg/s)');
        subplot 248;
        plot(thisTrip(:,12)); ylabel('Curvature (1/m)');
    case 'map'
        %fPlotMap = figure('Name','Plot data');
        plot(thisTrip(:,4),thisTrip(:,3),'b.','MarkerSize',8);
        hold on;
        plot(thisTrip([1 end],4),thisTrip([1 end],3),'rx','MarkerSize',10);
        stxt = text(thisTrip(1,4),thisTrip(1,3),'Start','Color','red','FontSize',12);
        etxt = text(thisTrip(end,4),thisTrip(end,3),'End','Color','red','FontSize',12);
        if addressOn == 1
            gpsAddress = getAddressByGPS(thisTrip(1,[3 4]));

        end
        meanspeed=[];
        tripLen = day1F_Re.TripLen(index);
        for i = 1:floor(tripLen/50):tripLen
        text(thisTrip(i,4),thisTrip(i,3),num2str(i,'%i'),'Color','black','FontSize',8);
        end
        if ~isempty(dataNum)
          dtxt = text(thisTrip(dataNum,4),thisTrip(dataNum,3),num2str(dataNum,'%i'),'Color','red','FontSize',24);
        end
        hold off;

        if isempty(mapType) 
        plot_google_map;
        else 
            plot_google_map('MapType',mapType);
        end
        title({sprintf('TripID: %5i',tripID),gpsAddress});
        
        
        
        
    case 'feat'
        %fPlotFeat = figure('Name','Plot data feature');
        subplot 241;
        plot(thisTrip(:,5)); ylabel('Elevation (m)');
        subplot 242;
        plot(thisTrip(:,6)); ylabel('Speed (m/s)');
        meanspeed =mean(thisTrip(:,6));
        subplot 243;
        plot(thisTrip(:,7)); ylabel('Heading (deg)');
        subplot 244;
        plot(thisTrip(:,8)); ylabel('Ax (m/s^2)');
        subplot 245;
        plot(thisTrip(:,9)); ylabel('Ay (m/s^2)');
        subplot 246;
        plot(thisTrip(:,10)); ylabel('Az (m/s^2)');
        subplot 247;
        plot(thisTrip(:,11)); ylabel('Yawrate (deg/s)');
        subplot 248;
        plot(thisTrip(:,12)); ylabel('Curvature (1/m)');
end

end



