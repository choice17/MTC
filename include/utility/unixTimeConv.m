function [matDateStr,matDateNum] = unixTimeConv(unix_time,dateFormat)
%% matlabTime = unixTimeConv(unix_time)
% Objective: convert unix time stamp to matlab time format
% input:     unix time stamp vector 
% output:    matlab date string, date number
%            
% example:   ----------------------------------
%             unix_time = 1506721665.97253;
%             [matDateStr,matDateNum] = unixTimeConv(unix_time,dateFormat)
%
%            ----------------------------------

if nargin == 1
    dateFormat = 'yyyy/mm/dd HH:MM:SS.FFF';
end


unix_time_ref = datenum('01/01/1970','mm/dd/yyyy');
unixTime = unix_time;
unixTime = unixTime./(60*60*24);

matDateNum = unix_time_ref + unixTime;
matDateStr = datestr(matDateNum,dateFormat);

end