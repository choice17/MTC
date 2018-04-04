function [out_date, date_num]= datanum2date(in_num,dateformat)
%  [out_date, date_num]= datanum2date(in_num,dateformat)
%  Objective:
%  absolute time is generated in microsecond from 2004 Jan 1
%  input:  time stamp on Collection1 and collection4 datanum2date
%  overload input: dateformat (specified the output format)
%  output: date time format in yyyy/mm/dd HH:MM:SS.FFF 
%  created by tcyu@umich.edu

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
