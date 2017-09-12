classdef TripInfo
   
    properties
      TripID;
      LengthOfTrip;
      StartPoint;
      NormalizeInfo;
      StandardizeTrip;
      Note='NormalizeInfo [std mean] is evenly split for features';
      
    end
    
    methods
      function obj = TripInfo(in_oneTrip)
      if nargin<1 
          obj.TripID=[];
      obj.LengthOfTrip=[];
      obj.StartPoint=[];
      obj.NormalizeInfo=[];
      obj.StandardizeTrip=[];
      else 
          obj=setTripInfo(obj,in_oneTrip);
      end
      end
         
      function obj=setTripInfo(obj,in_oneTrip)
          trip = in_oneTrip;
          obj = setTripLength(obj,trip);
          obj = setTripID(obj,trip);
  %        obj = setTripStartPoint(obj,trip);
  %        obj = setTripNormalizeInfo(obj,trip);
  %        obj = setTripStandardizeTrip(obj,trip);          
      end
      
      function obj = setTripLength(obj,in_oneTrip)
          trip = in_oneTrip;
          Len = length(trip(:,2));
          obj.LengthOfTrip = Len;          
      end
      
       function obj = setTripID(obj,in_oneTrip)
          trip = in_oneTrip;
           ID =unique(trip(:,2));
          if length(ID)~=1
              fprintf('error! more than one trip\n');
          else 
                obj.TripID = ID;
          end          
      end
          
              
              
   end
end