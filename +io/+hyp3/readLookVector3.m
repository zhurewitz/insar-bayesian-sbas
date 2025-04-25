%% HyP3 Read Look Vector
% Reads look vectors onto a regular, axis-aligned grid

function [LAT,LONG,INC,AZ,LX,LY,LZ]= readLookVector3(filename,lat,long)

arguments
    filename
    lat= [];
    long= [];
end

[LATp,LONGp,INCp,AZp,LXp,LYp,LZp]= io.hyp3.readLookVector(filename);

dL= 0.1;

% Fill query points
if isempty(lat)
    latmin= min(LATp,[],'all','omitmissing');
    latmax= max(LATp,[],'all','omitmissing');
    lat= (floor(latmin/dL)-1:ceil(latmax/dL)+1)*dL;
end

if isempty(long)
    longmin= min(LONGp,[],'all','omitmissing');
    longmax= max(LONGp,[],'all','omitmissing');
    long= (floor(longmin/dL)-1:ceil(longmax/dL)+1)*dL;
end

if isvector(long) && isvector(lat)
    [LONG,LAT]= meshgrid(long,lat);
else
    LONG= long;
    LAT= lat;
end

% Fit 2-order 2D polynomial surface
Afunc= @(x,y) [ones(length(x),1) x y x.^2 y.^2 x.*y];
Ap= Afunc(LONGp(:),LATp(:)); % Scattered points
A= Afunc(LONG(:),LAT(:)); % Regular points

% Estimate parameters
pinc= Ap\double(INCp(:));
paz= Ap\double(AZp(:));
px= Ap\double(LXp(:));
py= Ap\double(LYp(:));
pz= Ap\double(LZp(:));

Size= size(LAT);

% Extrapolate
INC= reshape(A*pinc,Size);
AZ= reshape(A*paz,Size);
LX= reshape(A*px,Size);
LY= reshape(A*py,Size);
LZ= reshape(A*pz,Size);

end