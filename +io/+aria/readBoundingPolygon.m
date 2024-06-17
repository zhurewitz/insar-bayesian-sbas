%% Read Bounding Polygon

function BB= readBoundingPolygon(filename)

try
    S= ncread(filename,'productBoundingBox')';
    S= S(11:end);
    BB= reshape(sscanf(S,'%f %f,'),2,[]);
catch ME
    BB= [];
end

end
