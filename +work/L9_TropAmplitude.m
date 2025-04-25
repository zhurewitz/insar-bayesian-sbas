
load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);

if ~exist("Troposphere",'var')
    Troposphere= d3.read(TroposphereFile);
end

load GNSS4LOSdemean.mat ID Ix Iy ReferenceID


%%

[~,I]= intersect(ID,ReferenceID);

IXR= Ix(I);
IYR= Iy(I);

sta= 9;

iq= IXR(sta);
jq= IYR(sta);

qTS= Troposphere(jq,iq,:);

MEAN= mean(Troposphere,3,'omitmissing');
STD= std(Troposphere,[],3,'omitmissing');
STD2= std(Troposphere- qTS,[],3,'omitmissing');

%%

max(STD,[],'all','omitmissing')
max(STD2,[],'all','omitmissing')

std(STD,[],'all','omitmissing')
std(STD2,[],'all','omitmissing')

%%



figure(1)
clf
setFigureSize(800,400)
imagesc([STD2 STD])
hold on
scatter(iq,jq,50,'kd','filled')
scatter(iq,jq,10,'w','filled')
scatter(IXR+ length(GridLong),IYR,50,'kd','filled')
scatter(IXR+ length(GridLong),IYR,10,'w','filled')
c= colorbar;
c.Label.String= "STD. LOS Tropospheric Delay (mm)";
setOptions
axis off
clim([0 1]*25)
colormap2 sunset
daspect([1 cosd(35) 1])

text(10,20,'a','Color','w','Units','pixels',...
    'FontSize',30,'FontName','Times',FontWeight='bold')
text(300,20,'b','Color','w','Units','pixels',...
    'FontSize',30,'FontName','Times',FontWeight='bold')

savePDF("Figures/tropAmplitude.pdf")
