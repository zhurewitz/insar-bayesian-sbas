%% Topography Shading

function illumination= topographyShading(Elevation)

[GX,GY]= gradient(Elevation);

GX= GX/111000*1200;
GY= GY/111000*1200;

Normal= cat(3,-GX,-GY,ones(size(Elevation)));
Normal= Normal./sqrt(sum(Normal.^2,3));

sunVector= [-1 1 1];
sunVector= sunVector/norm(sunVector);

illumination= sum(Normal.*reshape(sunVector,1,1,3),3);
illumination(illumination < 0)= 0;

end