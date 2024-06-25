%% Read Bounding Box

function BoundingBox= readBoundingBox(filename)

[dir,name]= fileparts(filename);

filename= fullfile(dir,name,strcat(name,'_unw_phase.tif'));

info= geotiffinfo(filename);
crs= info.SpatialRef.ProjectedCRS;

[lat1,long1]= projinv(crs,info.BoundingBox(1,1),info.BoundingBox(1,2));
[lat2,long2]= projinv(crs,info.BoundingBox(2,1),info.BoundingBox(2,2));

BoundingBox= [long1-.1 long2+.1 lat1-.1 lat2+.1];

end

