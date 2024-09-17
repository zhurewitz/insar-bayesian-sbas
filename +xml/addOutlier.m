%% Add Outlier

function addOutlier(filename,ID,OutlierDate,Attribution)

arguments
    filename (1,1) string
    ID (1,1) string
    OutlierDate (1,1) datetime
    Attribution= "";
end

Attribution= xml.utils.authorToAttribution(Attribution);


%% Read File

if exist(filename,'file')
    S= readstruct(filename);
else
    S= struct;
end

[i,j]= xml.utils.findPosition(S,ID,"Outlier");


%% Write to Struct

S.Station(i).idAttribute= ID;
if j == 1
    S.Station(i).Outlier= struct;
end
S.Station(i).Outlier(j).Date= OutlierDate;
S.Station(i).Outlier(j).Attribution= Attribution;


%% Write File

writestruct(S,filename)

end