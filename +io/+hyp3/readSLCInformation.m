%% Read SLC Information

function T= readSLCInformation(JSONfilename)

A= readstruct(JSONfilename,"FileType","json");

N= length(A.features);

fileID= repmat("",N,1);
Date= NaT(N,1);
Track= NaN(N,1);

for j= 1:N
    fileID(j)= extractBefore(A.features(j).properties.fileID,"-SLC");
    s= split(A.features(j).properties.startTime,'T');
    Date(j)= datetime(s(1),'InputFormat','yyyy-MM-dd');
    Track(j)= A.features(j).properties.pathNumber;
end

T= table;
T.FileID= fileID;
T.Date= Date;
T.Track= Track;

x= nan(N,4);
y= nan(N,4);

for j= 1:N
    for i= 1:4
        x(j,i)= A.features(j).geometry.coordinates{1}{i}(1);
        y(j,i)= A.features(j).geometry.coordinates{1}{i}(2);
    end
end


CentroidLatitude= nan(N,1);
for j= 1:N
    T.Polyshape(j)= polyshape(x(j,:),y(j,:));
    [~,cy]= centroid(T.Polyshape(j));
    
    CentroidLatitude(j)= cy;
end

% Sort by latitude then date
[~,I]= sort(CentroidLatitude);
T= T(I,:);
T= sortrows(T,"Date");



end
