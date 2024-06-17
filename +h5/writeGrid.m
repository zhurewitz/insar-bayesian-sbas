%% Write Formatted Grid Struct to HDF5 File

function writeGrid(filename,path,grid)

utils.checkGrid(grid)

h5.write(filename,path,'latitude',grid.Lat)
h5.write(filename,path,'longitude',grid.Long)

if h5.exist(filename,path,'latitude')
    h5writeatt(filename,fullfile(path,'latitude'),'dL',grid.dL)
    h5writeatt(filename,fullfile(path,'latitude'),'limits',grid.LatLim)
    h5writeatt(filename,fullfile(path,'latitude'),'size',grid.Size(1))
    h5writeatt(filename,fullfile(path,'latitude'),'units',grid.Units)
end

if h5.exist(filename,path,'longitude')
    h5writeatt(filename,fullfile(path,'longitude'),'dL',grid.dL)
    h5writeatt(filename,fullfile(path,'longitude'),'limits',grid.LongLim)
    h5writeatt(filename,fullfile(path,'longitude'),'size',grid.Size(2))
    h5writeatt(filename,fullfile(path,'longitude'),'units',grid.Units)
end

end