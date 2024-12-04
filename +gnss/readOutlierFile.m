%% Read Outliers from File
% Outlier file must be a plain text file where each row has the format:
% ID yyyyMMdd yyyyMMdd yyyyMMdd ...
%
% where the yyyyMMdd are the dates of each outlier in the timeseries in
% year/month/day format.
%
% Example:
% COSO 20190705 20190706 
% P579 20071017 20071021 20090503 20090505 20151223 20190705 20190706

function OutlierDates= readOutlierFile(filename,ID)

S= readlines(filename,'EmptyLineRule','skip');

fileID= extractBefore(S,5);
I= fileID == ID;

s= extractAfter(S(I),5);
OutlierDates= datetime(split(s),'InputFormat','yyyyMMdd');
OutlierDates(isnat(OutlierDates))= [];

end