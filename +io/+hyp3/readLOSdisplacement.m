%% Read Line-of-Sight Displacement -- HyP3 Format

function [LOSdisplacement,frameLat,frameLong,correlation]= ...
    readLOSdisplacement(filename)

dL= 1/1200;

metaData= io.hyp3.shortMetaData(filename);

losfilename= fullfile(metaData.Fullname,strcat(metaData.Filename,'_los_disp.tif'));
corrfilename= fullfile(metaData.Fullname,strcat(metaData.Filename,'_corr.tif'));

boundingBox= io.readBoundingBox(filename);

frameLong= (floor(boundingBox(1)/dL)-1:ceil(boundingBox(2)/dL)+1)*dL;
frameLat= (floor(boundingBox(3)/dL)-1:ceil(boundingBox(4)/dL)+1)*dL;

% Query points
% Note: only querying within the bounding box for efficiency
[LONGQ,LATQ]= meshgrid(frameLong,frameLat);

% Read raster and projection information
[LOSproj,R]= readgeoraster(losfilename);
LOSproj= 1000*LOSproj; % Convert from m to mm
I= LOSproj == 0;
LOSproj(I)= nan; % Missing data -> NaN

% Read correlation file
[corrproj,~]= readgeoraster(corrfilename);
corrproj(I)= nan; % Missing data -> NaN

% Raster CRS local coordinates
x= R.XWorldLimits(1):R.SampleSpacingInWorldX:R.XWorldLimits(2);
y= flip(R.YWorldLimits(1):R.SampleSpacingInWorldY:R.YWorldLimits(2));

% Project query pixels into CRS
[XQ,YQ]= projfwd(R.ProjectedCRS,LATQ,LONGQ);

% Interpolate LOS and correlation
LOSdisplacement= interp2(x,y,LOSproj,XQ,YQ,'nearest');
correlation= interp2(x,y,corrproj,XQ,YQ,'nearest');


end