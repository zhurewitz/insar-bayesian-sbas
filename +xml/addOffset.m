%% Add Offset

function addOffset(filename,ID,OffsetDate,EastValue,NorthValue,UpValue,Attribution,Units)

arguments
    filename (1,1) string
    ID (1,1) string
    OffsetDate (1,1) datetime
    EastValue {mustBeScalarOrEmpty,mustBeNumeric} = [];
    NorthValue {mustBeScalarOrEmpty,mustBeNumeric} = [];
    UpValue {mustBeScalarOrEmpty,mustBeNumeric} = [];
    Attribution= "";
    Units (1,1) string= "mm";
end

Attribution= xml.utils.authorToAttribution(Attribution);


%% Read File

if exist(filename,'file')
    S= readstruct(filename);
else
    S= struct;
end

[i,j]= xml.utils.findPosition(S,ID,"Offset");


%% Write to Struct

S.Station(i).idAttribute= ID;

if isfield(S.Station(i),"Offset") && isscalar(S.Station(i).Offset) && ismissing(S.Station(i).Offset)
    S.Station(i).Offset= struct;
end

S.Station(i).Offset(j).Date= OffsetDate;
if ~isempty(EastValue) && ~isnan(EastValue)
    S.Station(i).Offset(j).East= EastValue;
end
if ~isempty(NorthValue) && ~isnan(NorthValue)
    S.Station(i).Offset(j).North= NorthValue;
end
if ~isempty(UpValue) && ~isnan(UpValue)
    S.Station(i).Offset(j).Up= UpValue;
end
ENU= [EastValue NorthValue UpValue];
if ~isempty(ENU) && ~all(isnan(ENU))
    S.Station(i).Offset(j).Units= Units;
end
if ~isempty(fieldnames(Attribution))
    S.Station(i).Offset(j).Attribution= Attribution;
end



%% Write File

writestruct(S,filename)

end