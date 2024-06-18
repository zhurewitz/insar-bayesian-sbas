%% Import DEM
% Import SRTM 90m DEM onto the common grid.

function importElevation(h5filelist,APIkey,Timeout)

arguments
    h5filelist
    APIkey
    Timeout= 30;
end

h5filename= h5filelist(1);

if ~h5.exist(h5filename)
    error('File %s does not exist',h5filename)
end

commonGrid= h5.readGrid(h5filename,'/grid');

Elevation= utils.importSRTM90m(APIkey,commonGrid.Lat,commonGrid.Long,Timeout);


for i= 1:length(h5filelist)
    h5filename= h5filelist(i);

    if h5.exist(h5filename)
        h5.write2D(h5filename,'/grid','elevation',single(Elevation))
        h5.writeatts(h5filename,'/grid','elevation','units','m',...
            'source','SRTM','resolution','90m')
    else
        warning('File %s does not exist',h5filename)
    end
end


end