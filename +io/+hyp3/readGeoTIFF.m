%% Read GeoTIFF -- HyP3 Format

function [Z,frameLat,frameLong]= readGeoTIFF(filename)

dL= 1/1200;

boundingBox= io.hyp3.readBoundingBox(filename);

frameLong= (floor(boundingBox(1)/dL)-1:ceil(boundingBox(2)/dL)+1)*dL;
frameLat= (floor(boundingBox(3)/dL)-1:ceil(boundingBox(4)/dL)+1)*dL;

% Query points
% Note: only querying within the bounding box for efficiency
[LONGQ,LATQ]= meshgrid(frameLong,frameLat);

% Read raster and projection information
[Zproj,R]= readgeoraster(filename);

% Raster CRS local coordinates
x= R.XWorldLimits(1):R.SampleSpacingInWorldX:R.XWorldLimits(2);
y= flip(R.YWorldLimits(1):R.SampleSpacingInWorldY:R.YWorldLimits(2));

% Project query pixels into CRS
[XQ,YQ]= projfwd(R.ProjectedCRS,LATQ,LONGQ);

% Interpolate LOS and correlation
Z= interp2(x,y,Zproj,XQ,YQ,'nearest');


end