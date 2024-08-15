%% Append Manual Offset to File
% A new offset is logged in the same format as the equipment change
% offsets. 
% Inputs
%   filename - name of file where offsets are logged
%   StationID - 4-character ID of GNSS station
%   OffsetDate - datetime of offset
%   Author - Name or identifying information of author. Spaces are removed.
%       Author information is optional but recommended, especially to
%       receive credit.
%   InformationFlag (optional, default false) - If true, read the 'Author'
%       input as the full Information line (i.e. Manual-AuthorName-LogDate)
% 
% Format
%   StationID OffsetDate(YYMMDD) 3 Manual-AuthorName-LogDate(YYYYMMMDD)
%
% e.g. ANZA 190301 3 Manual-ZelHurewitz-2024May01
% meaning on May 1st, 2024, Zel Hurewitz manually logged an offset at the
% ANZA station which happened on March 1st, 2019.

function appendManualOffset(filename, StationID, OffsetDate, Author, InformationFlag)

arguments
    filename
    StationID
    OffsetDate
    Author= "";
    InformationFlag= false;
end

if InformationFlag && isempty(Author)
    InformationFlag= false;
end


Author= replace(Author,' ','');

datestr= upper(string(OffsetDate,'yyMMMdd'));

if InformationFlag
    InformationString= Author;
else
    if ~isempty(Author)
        AuthorString= strcat("-",Author);
    else
        AuthorString= "";
    end

    logString= string(datetime('today'),'yyyyMMMdd');
    
    InformationString= sprintf("Manual%s-%s",AuthorString,logString);
end

Line= sprintf('%s %s 3 %s',StationID,datestr,InformationString);

writelines(Line,filename,'WriteMode','append')

end

