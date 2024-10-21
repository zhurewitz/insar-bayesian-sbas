%% Place Interferogram on Common Grid

function [LOS,COH,CON]= placeInterferogramOnCommonGrid(commonGrid,...
    infLong,infLat,displacementLOS,coherence,connComp,OCEAN)

dL= commonGrid.dL;

% Calculate intersection
[~,ia_long,ib_long]= intersect(round(commonGrid.Long/dL),round(infLong/dL));
[~,ia_lat,ib_lat]= intersect(round(commonGrid.Lat/dL),round(infLat/dL));

% Add to grid
if ~isempty(ia_long) && ~isempty(ia_lat)

    LOS= nan(commonGrid.Size,'single');
    LOS(ia_lat,ia_long)= displacementLOS(ib_lat,ib_long);
    LOS(OCEAN)= nan;

    COH= nan(commonGrid.Size,'single');
    COH(ia_lat,ia_long)= coherence(ib_lat,ib_long);
    COH(OCEAN)= nan;

    if ~isempty(connComp)
        CON= false(commonGrid.Size);
        CON(ia_lat,ia_long)= connComp(ib_lat,ib_long);
        CON(OCEAN)= false;
    else
        CON= [];
    end
else
    fprintf('Stitched interferogram does not intersect.\n')
    return
end

end
