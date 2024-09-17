%% Convert to Datetime or Empty

function a= convertToDatetimeOrEmpty(a)
if ~isempty(a)
    a= returnValidDatetime(a);
end
end

function a= returnValidDatetime(a)
arguments
    a datetime
end
end
