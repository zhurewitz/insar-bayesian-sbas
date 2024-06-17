%% Read Perpendicular Baseline

function [baseline,long,lat]= readBaseline(filename)

baseline= ncread(filename,'/science/grids/imagingGeometry/perpendicularBaseline');
long= ncread(filename,'/science/grids/imagingGeometry/longitudeMeta');
lat= ncread(filename,'/science/grids/imagingGeometry/latitudeMeta');

baseline= baseline(:,:,2)';
