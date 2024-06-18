%% Read Interferogram

function [unwrappedPhase, lat, long]= readInterferogram(filename)

unwrappedPhase= single(ncread(filename,'/science/grids/data/unwrappedPhase'));
unwrappedPhase= unwrappedPhase';

[lat,long]= io.aria.readLatLong(filename);

end