%% Overwrite Manual Offset File
% Delete manual offset file and overwrite a new step file with the arrays
% StationID, OffsetDate, and Information

function overwriteManualOffsets(filename, StationID, OffsetDate, Information)

arguments
    filename
    StationID
    OffsetDate
    Information= repmat("",length(StationID),1);
end

if iscellstr(StationID) || ischar(StationID) %#ok<ISCLSTR>
    StationID= string(StationID);
end

if exist(filename,'file')
    delete(filename)
end

for i= 1:length(StationID)
    gnss.appendManualOffset(filename,StationID(i),OffsetDate(i),Information(i), true)
end

end