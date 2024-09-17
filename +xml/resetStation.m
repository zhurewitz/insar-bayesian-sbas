%% Reset Station

function resetStation(filename,ID,type)

arguments
    filename (1,1) string
    ID (1,1) string
    type {mustBeMember(type,["","Quality", "Range", "Outlier", "Offset"])}= "";
end

if isfile(filename)
    S= readstruct(filename);
else
    S= struct;
end

if isfield(S,"Station") && isfield(S.Station,"idAttribute")
    i= find(strcmpi([S.Station.idAttribute],ID),1);

    if isempty(i)
        return
    end
end

if isequal(type,"")
    S.Station(i)= [];
else
    if ~isfield(S.Station(i),type)
        return;
    end
    S.Station(i).(type)= [];
end

writestruct(S,filename)

end