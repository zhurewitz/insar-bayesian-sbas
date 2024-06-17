%% Import SRTM 90m DEM
% Import Shuttle Radar Topography Mission (SRTM) 90-meter resolution
% elevation data (Digital Elevation Model or DEM) onto the query grid.
% Inputs:
%   APIkey - myOpenTopo API key (for key generation see
%   https://portal.opentopography.org/myopentopo)
%   GridLat - vector, length Ny, of latitudes of grid cell centers
%   GridLong - vector, length Nx, of longitudes of grid cell centers
%   Timeout - (optional) time to allow request. Default 30s
% Output:
%   Elevation - Ny x Nx matrix of elevations in meters above sea level

function Elevation= importSRTM90m(APIkey,GridLat,GridLong,Timeout)

arguments
    APIkey
    GridLat
    GridLong
    Timeout= 30;
end

% Include a buffer zone for interpolation
LatLim= [min(GridLat) max(GridLat)] + .01*[-1 1];
LongLim= [min(GridLong) max(GridLong)] + .01*[-1 1];

geostring= sprintf('south=%0.2f&north=%0.2f&west=%0.2f&east=%0.2f', ...
    LatLim(1),LatLim(2),LongLim(1),LongLim(2));

requestURL= strcat('https://portal.opentopography.org/API/globaldem?demtype=SRTMGL3&', ...
    geostring, '&outputFormat=GTiff&API_Key=', APIkey);

% Save as a temporary GeoTiff file
tempfilename= [tempname,'.tif'];
options= weboptions('Timeout',Timeout);
fullfilename= websave(tempfilename,requestURL,options);

% Read GeoTIFF file raster and geographic data, then delete
[A,R]= readgeoraster(fullfilename);
A= flip(A);
try
    delete(fullfilename)
catch
end

% Interpolate onto the grid
dL= R.CellExtentInLatitude;
TiffLat= R.LatitudeLimits(1)+ .5*dL:dL:R.LatitudeLimits(2);
dL= R.CellExtentInLongitude;
TiffLong= R.LongitudeLimits(1)+ .5*dL:dL:R.LongitudeLimits(2);

[LONG,LAT]= meshgrid(GridLong,GridLat);

Elevation= interp2(TiffLong,TiffLat,double(A),LONG,LAT);
Elevation(Elevation == 0)= nan;

end


% Note: to get grid cell centers instead of edges, we have to use the .5*dL
% offset when making Lat and Long. At least I think so, and the code
% referenced below does so as well:
% https://github.com/OpenTopography/Visualize_Topography_Data_In_Matlab/blob/main/read_visualize_raster.m 
