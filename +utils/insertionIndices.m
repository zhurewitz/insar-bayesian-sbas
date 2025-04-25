function [Iax,Iay,Ibx,Iby]= insertionIndices(gridLong,gridLat,inLong,inLat)

dL= abs(diff(gridLong(1:2)));
[~,Iax,Ibx]= intersect(round(gridLong/dL),round(inLong/dL));
dL= abs(diff(gridLat(1:2)));
[~,Iay,Iby]= intersect(round(gridLat/dL),round(inLat/dL));

end