function [index,problemFlag,tripInfo] = gofindTripWithAttr(tripTrain_obj,option)
% [index,problemFlag,tripInfo] = gofindTripWithAttr(tripTrain_obj,option)
% Objective: To find the specific trip index by defined option
%            Used for select specified trip category
% input    : tripTrain_obj, day1TripTrain obj
%          : option - to defined the parameter of tripinfo to be extracted
%            option.maxSpeed - trip max speed
%            option.indexRange - select the index range, *note. index
%                    should be listed as ascending value of trip length
%            option.addr - check if the addr name occurs in 1st GPS point
%                            data through google address api
%            option.dist - the total distance traveled in the trips
% output   : index:   trip index that fullfilled the option required
%            problemFlag: lists the flag fails for the trips
%            tripInfo: stored trip information related to full filled requirement 



%filterParameter
maxSpeed=option.maxSpeed;
indexRange = option.indexRange;
addr = option.addr;
dist = option.dist;
index = [];
problemFlag = zeros(length(indexRange),5);
%filterParameter (default value)
AxMax = 10;
AyMax = 10;
AzMax = 8;
freq = tripTrain_obj.getDataFreq();
timeDiff = -1000000/freq; %(1s/freq)
tripInfo.addr = {};
tripInfo.index = [];
tripInfo.dist = [];
tripInfo.maxSpeed = [];


j=1;
for i = indexRange
   skipFlag = 0;
   speedFlag = 0;
   distFlag = 0;
   addrFlag = 0;
   timeFlag = 0;    
   
   
   thisTrip = tripTrain_obj.TripInCell{i};
   %filter timeDiff
   thisTripTimeDiff = thisTrip(1:end-1,14) - thisTrip(2:end,14);
   %ifDisCont = find(thisTripTimeDiff ~= timeDiff, 1);
   ifDisCont = find(abs(thisTripTimeDiff - timeDiff)>-timeDiff*5, 1);
   if ~isempty(ifDisCont)
       skipFlag = 1;
       timeFlag = 1;
   end
   if skipFlag ~= 1
       %filter speed,ax,ay,az
       if (max(thisTrip(:,6))>maxSpeed || max(abs(thisTrip(:,8)))>AxMax || ...
           max(abs(thisTrip(:,9)))>AyMax || max(abs(thisTrip(:,10)))>AzMax)
           skipFlag = 1;
           speedFlag =1;
       end
       if skipFlag~=1 
           if ~isempty(dist)
               thisTripDist = tripTrain_obj.getTripDist('TripIndex',i);
                if thisTripDist>dist(2) || thisTripDist<dist(1)                    
                    skipFlag = 1;
                    distFlag = 1;
                end
           end
           if ~isempty(addr)
               if skipFlag~=1 
                   thisTripAddr = tripTrain_obj.getTripAddr('TripIndex',i);
                    if isempty(strfind(thisTripAddr,addr))
                        skipFlag = 1;
                        addrFlag = 1;
                    end
               end
           end
           if skipFlag==0
               index = [index i];
               tripInfo.index = index;
               if ~isempty(addr)
               tripInfo.addr = [tripInfo.addr;[thisTripAddr]];
               end
               tripInfo.dist = [tripInfo.dist thisTripDist];
               tripInfo.maxSpeed = [tripInfo.maxSpeed max(thisTrip(:,6))];
           end

       end
   end
   
   problemFlag(j,:) = [i timeFlag speedFlag distFlag addrFlag];
   j=j+1;
end
           
      
end
