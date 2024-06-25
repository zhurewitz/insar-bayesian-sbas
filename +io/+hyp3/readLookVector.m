%% HYP3 - Read Look Angles and Vector

function [LAT,LONG,INC,AZ,LX,LY,LZ]= readLookVector(filename)

[~,name]= fileparts(filename);

subSampleFactor= 100;

phifilename= fullfile(filename,strcat(name,'_lv_phi.tif'));
thfilename= fullfile(filename,strcat(name,'_lv_theta.tif'));

[PHI,R]= readgeoraster(phifilename);
PHI= PHI(1:subSampleFactor:end,1:subSampleFactor:end);

AZ= 180/pi*PHI;

THETA= readgeoraster(thfilename);
THETA= THETA(1:subSampleFactor:end,1:subSampleFactor:end);
INC= 90- 180/pi*THETA;

x= R.XWorldLimits(1):R.SampleSpacingInWorldX:R.XWorldLimits(2);
y= flip(R.YWorldLimits(1):R.SampleSpacingInWorldY:R.YWorldLimits(2));

x= x(1:subSampleFactor:end);
y= y(1:subSampleFactor:end);

[X,Y]= meshgrid(x,y);

[LAT,LONG]= projinv(R.ProjectedCRS,X,Y);

LX= cosd(AZ).*sind(INC);
LY= sind(AZ).*sind(INC);
LZ= cosd(INC);

end