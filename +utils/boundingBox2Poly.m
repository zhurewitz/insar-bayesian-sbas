%% Bounding Box To Polygon

function [polyLong,polyLat]= boundingBox2Poly(LongLim,LatLim)

polyLong= LongLim([1 2 2 1 1]);
polyLat= LatLim([1 1 2 2 1]);

end