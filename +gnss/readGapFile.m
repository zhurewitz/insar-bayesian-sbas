%% Read Gap File
% Data gap file must be a plain text file where each row has the format:
% ID yyyyMMdd yyyyMMdd 
%
% where the yyyyMMdd are the dates of the START and END of the data gap.
% Unlike the other files, each row contains only one data gap, and each
% station may have more than one row.
%
% Example:
% CAC2 20150101 20171118
% CAC2 20210611 20211102
% COSO 20150307 20180507


function [GapStart,GapEnd]= readGapFile(filename,ID)

S= readlines(filename,'EmptyLineRule','skip');

fileID= extractBefore(S,5);

I= find(fileID == ID);

GapStart= [];
GapEnd= [];

for k= 1:length(I)
    d= datetime(split(extractAfter(S(I(k)),5)),'InputFormat','yyyyMMdd');
    GapStart= [GapStart; d(1)]; %#ok<*AGROW>
    GapEnd= [GapEnd; d(2)];
end

end

