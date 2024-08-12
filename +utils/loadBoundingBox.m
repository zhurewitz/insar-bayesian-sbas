%% Load Bounding Box File

function [LongLim,LatLim]= loadBoundingBox(workdir)

boundingBox= readmatrix(fullfile(workdir,'boundingBox.txt'));
LongLim= boundingBox(1,:);
LatLim= boundingBox(2,:);

end