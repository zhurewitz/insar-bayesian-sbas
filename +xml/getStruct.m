%% Get Struct

function s= getStruct(filename,ID,type)

arguments
    filename (1,1) string
    ID (1,1) string= "";
    type {mustBeMember(type,["","Quality", "Range", "Outlier", "Offset"])}= "";
end

S= xml.readFile(filename);

if isequal(ID,"")
    s= [];
    return
end

[i,~,foundStation]= xml.utils.findPosition(S,ID,type);

if foundStation
    if isequal(type,"")
        s= S.Station(i);
    else
        if isfield(S.Station(i),type) && ~(isscalar(S.Station(i).(type)) && ismissing(S.Station(i).(type)))
            s= [S.Station(i).(type)];
        else
            s= [];
        end
    end
else
    s= [];
end

end

