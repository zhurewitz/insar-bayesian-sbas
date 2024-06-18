%% Write Formatted Grid Struct to HDF5 File

function writeGrid(filename,path,grid)

utils.checkGrid(grid)

h5.write(filename,path,'latitude',grid.Lat)
h5.write(filename,path,'longitude',grid.Long)

h5.writeatts(filename,path,'latitude','dL',grid.dL,'limits',grid.LatLim,...
    'size',grid.Size(1),'units',grid.Units,'valueRefersTo','cellLowerEdge')
h5.writeatts(filename,path,'longitude','dL',grid.dL,'limits',grid.LongLim,...
    'size',grid.Size(2),'units',grid.Units,'valueRefersTo','cellLeftEdge')

end