%% Read KMZ Polygon

function [polyLat,polyLong]= readKMZPolygon(filename)

S= readKMZStruct(filename);

coordstr= S.Document.Placemark.Polygon.outerBoundaryIs.LinearRing.coordinates;

coords= reshape(str2num(coordstr),3,[]); %#ok<ST2NM>

polyLong= coords(1,:);
polyLat= coords(2,:);

end



