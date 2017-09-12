function plottrip(vtrip,t,option)
% plottrip(vtrip,t,option)
% plottrip(tripInfo,t,option)
% vtrip : [vid trip lat long time vel]
% tripInfo .TripID .LengthOfTrip .StartPoint .meanTrip .NormalizeInfo
%          .CenterNormalizeInfo .StandardizeTrip .StandardizeTripCell 
%          .CenteredTrip .CenterTripCell .
% t     : pause time
% option: 'Y'-plot by points | 'N'-plot by trips

skipnum = 1;
ds = 0.005;
runtime = 0.005;


%%
hold on;
if size(vtrip,1)~=1
    
    uniq = unique(vtrip(:,2));
    N = size(uniq);
    if nargin <3
        option = 'N';
    end
    directline = 0;
    for i = 1:N
        color = [rand rand rand];
        lat = vtrip(vtrip(:,2)==uniq(i),3);
        long = vtrip(vtrip(:,2)==uniq(i),4);
        hold on;
        if strcmp(option,'Y')
            hold on;
            for j = 1:skipnum:length(vtrip(vtrip(:,2)==uniq(i),3))
                
                 axis([lat(j)-ds lat(j)+ds ...
                 long(j)-ds long(j,1)+ds ]);
                plot(lat(j),long(j),'.','Color',color)
                if j>1
                    if directline
                        delete(direction);
                    end
                distx = lat(j)-lat(j-1);
                disty = long(j) - long(j-1);
                direction = plot([lat(j) lat(j)+10*distx],[long(j) long(j)+10*disty],'y--','Linewidth',2);
                directline = 1;
                end
                pause(runtime);
            end
        else
        plot(lat,long,'Color',color);
        i
        pause();
        end
    
        pause(t);
    end
    hold off;

else
    Len = length(vtrip.LengthOfTrip);
    directline = 0;
    for i = 1:Len
        
        color = [rand rand rand];
        %[i vtrip.TripID(i,:)]
        index = (1+(i>1)*sum(vtrip.LengthOfTrip(1:i-1))): ...
            (sum(vtrip.LengthOfTrip(1:i))-1);
        lat = vtrip.StandardizeTrip(index,1);
        long = vtrip.StandardizeTrip(index,2);
        hold on;
        if strcmp(option,'Y')
            hold on;
            for j = 1:skipnum:length(lat)
                if mod(j,1000)==1 && j>1000 || j == length(lat)
                %j    
                end
                if directline
                    delete(direction);
                end
                axis([lat(j)-ds lat(j)+ds ...
        long(j)-ds long(j,1)+ds ]);
                plot(lat(j),long(j),'.','Color',color)
                distx = lat(j)-lat(j-1);
                disty = long(j) - long(j-1);
                direction = plot([lat(j) lat(j)+10*distx],[long(j) long(j)+10*disty],'y--','Linewidth',2);
                directline = 1;
                pause(0.01);
            end
        else
            plot(lat,long,'Color',color);
        end
    pause(t);    
    end
    
    
end
hold off;
    


end
    