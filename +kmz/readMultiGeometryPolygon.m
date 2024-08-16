%% Read KMZ Multi-Geometry Polygon

function [polyLat,polyLong]= readMultiGeometryPolygon(filename)

S= kmz.readKMZStruct(filename);

polyLong= [];
polyLat= [];

for i= 1:length(S.Document.Placemark.MultiGeometry.Polygon)
    coordstr= S.Document.Placemark.MultiGeometry.Polygon(i).outerBoundaryIs.LinearRing.coordinates;

    coords= reshape(str2num(coordstr),3,[]); %#ok<ST2NM>

    polyLong= [polyLong nan coords(1,1:end-1)]; %#ok<AGROW>
    polyLat= [polyLat nan coords(2,1:end-1)]; %#ok<AGROW>
end

polyLong(1)= [];
polyLat(1)= [];

end


