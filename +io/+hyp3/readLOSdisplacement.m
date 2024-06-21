%% Read Line-of-Sight Displacement

function LOSdisplacement= readLOSdisplacement(metaData,grid)

dL= grid.dL;

filename= fullfile(metaData.Fullname,strcat(metaData.Filename,'_los_disp.tif'));

boundingBox= metaData.BoundingBox;

bx= floor(boundingBox(1)/dL)-1:ceil(boundingBox(2)/dL)+1;
by= floor(boundingBox(3)/dL)-1:ceil(boundingBox(4)/dL)+1;

[~,iax,~]= intersect(round(grid.Long/dL),bx);
[~,iay,~]= intersect(round(grid.Lat/dL),by);

% Query points
% Note: only querying within the bounding box for efficiency
[LONGQ,LATQ]= meshgrid(grid.Long(iax),grid.Lat(iay));

% Read raster and projection information
[LOSproj,R]= readgeoraster(filename);
LOSproj= 1000*LOSproj; % Convert from m to mm
LOSproj(LOSproj == 0)= nan; % Missing data -> NaN

% Raster CRS local coordinates
x= R.XWorldLimits(1):R.SampleSpacingInWorldX:R.XWorldLimits(2);
y= flip(R.YWorldLimits(1):R.SampleSpacingInWorldY:R.YWorldLimits(2));

% Project query pixels into CRS
[XQ,YQ]= projfwd(R.ProjectedCRS,LATQ,LONGQ);

% Interpolate LOS
LOSdisplacement= nan(grid.Size,'single');
LOSdisplacement(iay,iax)= interp2(x,y,LOSproj,XQ,YQ,'nearest');

end