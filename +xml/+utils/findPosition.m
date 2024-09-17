%% Find Position Within Struct

function [i,j,foundStation]= findPosition(S,ID,type)

arguments
    S
    ID (1,1) string
    type {mustBeMember(type,["", "Quality","Range","Outlier","Offset"])}= "";
end

foundStation= false;

if isfield(S,"Station")
    if isfield(S.Station,"idAttribute")
        i= find(strcmpi([S.Station.idAttribute],ID),1);
    else
        i= find(strcmpi([S.Station.ID],ID),1);
    end

    if isempty(i)
        i= length(S.Station)+ 1;
        j= 1;
    else
        foundStation= true;
        if ~isequal(type,"") && isfield(S.Station(i),type)
            if isscalar(S.Station(i).(type)) && ismissing(S.Station(i).(type))
                j= 1;
            else
                j= length(S.Station(i).(type))+ 1;
            end
        else
            j= 1;
        end
    end
else
    i= 1;
    j= 1;
end

if strcmp(type,"Quality")
    j= 1;
end

end

