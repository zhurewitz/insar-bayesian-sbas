%% Set Quality Flag

function setQualityFlag(filename,ID,Value,Attribution)

arguments
    filename (1,1) string
    ID (1,1) string
    Value (1,1) logical = true;
    Attribution= "";
end

Attribution= xml.utils.authorToAttribution(Attribution);


%% Read File

if exist(filename,'file')
    S= readstruct(filename);
else
    S= struct;
end

if isfield(S,"Station") && isfield(S.Station(1),"idAttribute")
    i= find(strcmpi([S.Station.idAttribute],ID),1);

    if isempty(i)
        i= length(S.Station)+ 1;
    end
else
    i= 1;
end


%% Write to Struct and File

S.Station(i).idAttribute= ID;
S.Station(i).Quality.Value= Value;
S.Station(i).Quality.Attribution= Attribution;

writestruct(S,filename)


end