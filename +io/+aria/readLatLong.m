%% Read Latitude and Longitude

function [lat, long]= readLatLong(filename)

long= ncread(filename,'/science/grids/data/longitude');
lat= ncread(filename,'/science/grids/data/latitude');
long= long';

end
