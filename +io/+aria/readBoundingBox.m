%% Read Bounding Box

function boundingBox= readBoundingBox(filename)

% Read bounding box information
[Lat,Long]= io.aria.readLatLong(filename);
boundingBox= [min(Long) max(Long) min(Lat) max(Lat)];

end

