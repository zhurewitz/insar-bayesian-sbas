%% Add Range

function addRange(filename,ID,StartDate,EndDate,Attribution)

arguments
    filename (1,1) string
    ID (1,1) string
    StartDate {mustBeScalarOrEmpty} = [];
    EndDate {mustBeScalarOrEmpty} = [];
    Attribution= "";
end

StartDate= xml.utils.convertToDatetimeOrEmpty(StartDate);
EndDate= xml.utils.convertToDatetimeOrEmpty(EndDate);

Attribution= xml.utils.authorToAttribution(Attribution);


%% Load file

if exist(filename,'file')
    S= readstruct(filename);
else
    S= struct;
end

[i,j]= xml.utils.findPosition(S,ID,"Range");


%% Write to struct

S.Station(i).idAttribute= ID;

if isfield(S.Station(i),"Range") && isscalar(S.Station(i).Range) && ismissing(S.Station(i).Range)
    S.Station(i).Range= struct;
end

if ~isempty(StartDate) && ~isnat(StartDate)
    S.Station(i).Range(j).Start= StartDate;
end
if ~isempty(EndDate) && ~isnat(EndDate)
    S.Station(i).Range(j).End= EndDate;
end
if ~isempty(fieldnames(Attribution))
    S.Station(i).Range(j).Attribution= Attribution;
end


%% Write to file

writestruct(S,filename)


end