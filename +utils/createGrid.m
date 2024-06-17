%% Create Formatted Grid Struct

function grid= createGrid(LatLim,LongLim,dL,includeEdge)

arguments
    LatLim
    LongLim
    dL
    includeEdge= false;
end

if includeEdge
    offset= 0;
else
    offset= 1;
end

grid= struct;
grid.dL= dL;
grid.LatLim= LatLim;
grid.LongLim= LongLim;
grid.Lat= (round(LatLim(1)/dL):round(LatLim(2)/dL)-offset)*dL;
grid.Long= (round(LongLim(1)/dL):round(LongLim(2)/dL)-offset)*dL;
grid.Size= [length(grid.Lat) length(grid.Long)];
grid.Units= 'degrees';

end

