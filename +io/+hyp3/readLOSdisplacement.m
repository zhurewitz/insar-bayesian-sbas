%% Read Line-of-Sight Displacement -- HyP3 Format

function [LOSdisplacement,frameLat,frameLong,mask]= ...
    readLOSdisplacement(filename)

dL= 1/1200;

metaData= io.hyp3.shortMetaData(filename);

losfilename= fullfile(metaData.Fullname,strcat(metaData.Filename,'_los_disp.tif'));

boundingBox= io.readBoundingBox(filename);

frameLong= (floor(boundingBox(1)/dL)-1:ceil(boundingBox(2)/dL)+1)*dL;
frameLat= (floor(boundingBox(3)/dL)-1:ceil(boundingBox(4)/dL)+1)*dL;

% Query points
% Note: only querying within the bounding box for efficiency
[LONGQ,LATQ]= meshgrid(frameLong,frameLat);

% Read raster and projection information
[LOSproj,R]= readgeoraster(losfilename);
LOSproj= 1000*LOSproj; % Convert from m to mm
LOSproj(LOSproj == 0)= nan; % Missing data -> NaN

% Raster CRS local coordinates
x= R.XWorldLimits(1):R.SampleSpacingInWorldX:R.XWorldLimits(2);
y= flip(R.YWorldLimits(1):R.SampleSpacingInWorldY:R.YWorldLimits(2));

% Project query pixels into CRS
[XQ,YQ]= projfwd(R.ProjectedCRS,LATQ,LONGQ);

% Interpolate LOS
LOSdisplacement= interp2(x,y,LOSproj,XQ,YQ,'nearest');


% Interferogram mask -- land pixels within the interferogram frame
outside= zeros(size(LOSdisplacement));
CC= bwconncomp(isnan(LOSdisplacement));
[~,I]= max(cellfun(@length,CC.PixelIdxList));
pixlist= cell2mat(CC.PixelIdxList(I));
outside(pixlist)= 1;

mask= ~outside;


end