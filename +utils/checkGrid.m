
function checkGrid(grid)

arguments 
    grid= [];
end

if isempty(grid)
    fprintf('Grids must be structs with fields Lat,Long,LatLim,LongLim,dL,Size,Units\n')
else
    if ~isa(grid,'struct') || ~isfield(grid,'Lat') || ~isfield(grid,'Long')...
            || ~isfield(grid,'dL') || ~isfield(grid,'LatLim') || ~isfield(grid,'LongLim')...
            || ~isfield(grid,'Size') || ~isfield(grid,'Units')
        error('grid must be a struct with fields Lat,Long,LatLim,LongLim,dL,Size,Units')
    end
end

end



