%% Read Offsets
% Offset file must be a plain text file where each row has the format:
% ID yyyyMMdd yyyyMMdd yyyyMMdd ...
%
% where the yyyyMMdd are the dates of each offset in the timeseries in
% year/month/day format.
%
% Example:
% BEPK 20060626 20060720 20070405 20070629 20081214
% CCCC 20070515 20230310

function OffsetDates= readOffsetFile(filename,ID)

S= readlines(filename,'EmptyLineRule','skip');

fileID= extractBefore(S,5);
I= fileID == ID;

s= extractAfter(S(I),5);
OffsetDates= datetime(split(s),'InputFormat','yyyyMMdd');
OffsetDates(isnat(OffsetDates))= [];

end