%% Import DEM
% Import SRTM 90m DEM onto the common grid.

function importElevation(h5filename,APIkey,Timeout)

arguments
    h5filename
    APIkey
    Timeout= 30;
end

if ~h5.exist(h5filename)
    error('File %s does not exist',h5filename)
end

commonGrid= h5.readGrid(h5filename,'/grid');

Elevation= utils.importSRTM90m(APIkey,commonGrid.Lat,commonGrid.Long,Timeout);

h5.write2D(h5filename,'/grid','elevation',single(Elevation))
h5.writeatts(h5filename,'/grid','elevation','units','m','source','SRTM','resolution','90m')

end