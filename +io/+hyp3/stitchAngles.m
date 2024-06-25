%% HyP3 - Stitch Look Angles and Vectors

function [inclinationAngle,azimuthAngle,lookVectorX,lookVectorY,lookVectorZ]=...
    stitchAngles(filelist,metaGrid)

Nfiles= length(filelist);

% Read bounding boxes
boundingBoxes= zeros(Nfiles,4);
for i= 1:Nfiles
    filename= filelist(i);
    boundingBoxes(i,:)= io.readBoundingBox(filename);
end

% Sort by latitude
[~, I]= sort(boundingBoxes(:,4));
filelist= filelist(I);


inclinationAngle= nan(metaGrid.Size);
azimuthAngle= nan(metaGrid.Size);
lookVectorX= nan(metaGrid.Size);
lookVectorY= nan(metaGrid.Size);
lookVectorZ= nan(metaGrid.Size);

[LONGQ,LATQ]= meshgrid(metaGrid.Long,metaGrid.Lat);

for i= 1:Nfiles
    filename= filelist(i);
    
    % Read look vector
    [LAT,LONG,INC,AZ,LX,LY,LZ]= io.hyp3.readLookVector(filename);
    
    % Interpolate
    F= scatteredInterpolant(LONG(:),LAT(:),...
        double([INC(:) AZ(:) LX(:) LY(:) LZ(:)]),'linear','none');
    v= F(LONGQ(:),LATQ(:));
    
    % Fill where the data is missing
    Inan= isnan(inclinationAngle);
    
    tmp= reshape(v(:,1),metaGrid.Size);
    inclinationAngle(Inan)= tmp(Inan);
    tmp= reshape(v(:,2),metaGrid.Size);
    azimuthAngle(Inan)= tmp(Inan);
    tmp= reshape(v(:,3),metaGrid.Size);
    lookVectorX(Inan)= tmp(Inan);
    tmp= reshape(v(:,4),metaGrid.Size);
    lookVectorY(Inan)= tmp(Inan);
    tmp= reshape(v(:,5),metaGrid.Size);
    lookVectorZ(Inan)= tmp(Inan);
end

% Extrapolate to missing corners
inclinationAngle= extrapolate(inclinationAngle,metaGrid.Long,metaGrid.Lat);
azimuthAngle= extrapolate(azimuthAngle,metaGrid.Long,metaGrid.Lat);
lookVectorX= extrapolate(lookVectorX,metaGrid.Long,metaGrid.Lat);
lookVectorY= extrapolate(lookVectorY,metaGrid.Long,metaGrid.Lat);
lookVectorZ= extrapolate(lookVectorZ,metaGrid.Long,metaGrid.Lat);

end




function Z= extrapolate(Z,x,y)

x= x- mean(x);
y= y- mean(y);

p= utils.polyfit2D(x,y,Z,2);
Ztmp= utils.polyval2D(p,x,y);
Z(isnan(Z))= Ztmp(isnan(Z));

end



