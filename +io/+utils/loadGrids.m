%% Load Grids

function [commonGrid,metaGrid,dL,referenceTrendMatrix,commonTrendMatrix,...
    metaTrendMatrix,OCEAN,inReference,inStudyArea,Elevation]= ...
    loadGrids(h5filename)

commonGrid= h5.readGrid(h5filename,'/grid/');
metaGrid= h5.readGrid(h5filename,'/metaGrid/');

dL= commonGrid.dL;
referenceTrendMatrix= h5.read(h5filename,'/grid','referenceTrendMatrix');
commonTrendMatrix= h5.read(h5filename,'/grid','trendMatrix');
metaTrendMatrix= h5.read(h5filename,'/metaGrid','trendMatrix');
OCEAN= h5.read(h5filename,'/grid','oceanMask') == 1;
inReference= h5.read(h5filename,'/grid','referenceMask') == 1;
inStudyArea= h5.read(h5filename,'/grid','studyAreaMask') == 1;
Elevation= h5.read(h5filename,'/grid','elevation');

end