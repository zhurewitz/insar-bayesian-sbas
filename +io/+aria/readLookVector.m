%% Incidence and Azimuth Angles and Look Vector
% By convention, the look vector is upwards-oriented and points TOWARDS the
% satellite

function [metaLat,metaLong,incidenceAngle,lookAngle,azimuthAngle,...
    lookVectorX,lookVectorY,lookVectorZ]= readLookVector(filename)

metaLat= flip(ncread(filename,'/science/grids/imagingGeometry/latitudeMeta'));
metaLong= ncread(filename,'/science/grids/imagingGeometry/longitudeMeta');
% metaHeight= ncread(filename,'/science/grids/imagingGeometry/heightsMeta');
incidenceAngle= pagetranspose(ncread(filename,'/science/grids/imagingGeometry/incidenceAngle'));
incidenceAngle= flip(incidenceAngle(:,:,2));
lookAngle= pagetranspose(ncread(filename,'/science/grids/imagingGeometry/lookAngle'));
lookAngle= flip(lookAngle(:,:,2));
azimuthAngle= pagetranspose(ncread(filename,'/science/grids/imagingGeometry/azimuthAngle'));
azimuthAngle= flip(azimuthAngle(:,:,2));

lookVectorX= cosd(azimuthAngle).*sind(incidenceAngle);
lookVectorY= sind(azimuthAngle).*sind(incidenceAngle);
lookVectorZ= cosd(incidenceAngle);

end