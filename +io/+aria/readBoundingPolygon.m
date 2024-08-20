%% Read Bounding Polygon

function [Long,Lat]= readBoundingPolygon(filename)

try
    s= string(ncread(filename,"productBoundingBox")');

    coords= reshape(str2num(extractBetween(s,'((','))')),2,[]); %#ok<ST2NM>

    Long= coords(1,:)';
    Lat= coords(2,:)';

catch ME
    Long= [];
    Lat= [];
end

end
