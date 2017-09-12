function [out_date, date_num]= datanum2date(in_num,dateformat)
% for day1_fullSec 
% absolute time is generated in microsecond from 2004 Jan 1
if nargin ==1
    dateformat = 'yyyy/mm/dd HH:MM:SS.FFF';
end
% time unit micro-second us
timeunit = 1e-6;
absolute_time = in_num;
startday = datenum(2004,1,1);
daynum = absolute_time./(86400/timeunit);
date_num = startday + daynum;
out_date = datestr(date_num,dateformat);
end
