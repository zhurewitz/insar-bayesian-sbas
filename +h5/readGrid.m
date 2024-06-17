
function grid= readGrid(filename,groupname)

grid= struct();

datasetname= fullfile(groupname,'latitude');
grid.Lat= h5read(filename,datasetname);
grid.LatLim= h5readatt(filename,datasetname,'limits');
grid.dL= h5readatt(filename,datasetname,'dL');
grid.Units= h5readatt(filename,datasetname,'units');
grid.Size= [h5readatt(filename,datasetname,'size') NaN];

datasetname= fullfile(groupname,'longitude');
grid.Long= h5read(filename,datasetname);
grid.LongLim= h5readatt(filename,datasetname,'limits');
grid.Size(2)= h5readatt(filename,datasetname,'size');

end
