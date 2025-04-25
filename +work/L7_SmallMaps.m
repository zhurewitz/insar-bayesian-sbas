%% Parameter Maps


load input71.mat workdir datadir

ParamFile= fullfile(workdir,"L6output.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";


%% Load

load faults.mat


load(GNSSFile,"GNSSDate","GNSSReferenced","ID","StationLatitude","StationLongitude")
GNSS= GNSSReferenced;

B= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],1.8);

GNSSParamMean= utils.fitParams(GNSS,B);


load(ParamFile,"GridLat","GridLong","Coseismic","PostSeismic","Velocity","RMSE")


load Elevation.mat Elevation
illuminationImage= backgroundIllumination2(Elevation);


load(CovFile,"PosteriorCovariance","Date")

A= utils.parameterMatrix2(Date,1,1,1,0,0,[],1.8);

iA= (A'*A)\A';

InSARParamCovariance= iA*PosteriorCovariance*iA';
InSARSigmaUncertainty= sqrt(diag(InSARParamCovariance));





%% Read LookVector

% [~,filelist]= io.aria.listDirectory(datadir);
% 
% [metaLat,metaLong,~,~,~,LX,LY,LZ]= io.aria.readLookVector(filelist{1});

LookVector= [.60,-.11,.784];




%%

CLIM= [-1 1]*5;
k= 1;

figure(1)
clf
set(gcf,'Position',[1    77   600   550])
[~,c]= plotImage2(Velocity,illuminationImage,GridLong,GridLat,[],CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude,StationLatitude,150,GNSSParamMean(k,:),'filled',...
    "MarkerEdgeColor",'k')
hold on

set(gca,'Position',[.08 .2 .85 .75])
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Location= "southoutside";
c.Label.String= "Away"+ join(repmat(" ",19,1))+...
    "LOS Velocity (mm/yr)"+ join(repmat(" ",19,1))+ "Towards";
% plotLVDescending(LookVector)
% scaleBar


exportgraphics(gcf,"Figures/smallmap_velocity.pdf","ContentType","vector",'BackgroundColor','none')







function scaleBar

r= 50;
long1= -117.15;
lat1= 35.02;

[lat2,long2]= scaleBarkm(lat1,long1,r,2,10);

text(long1,lat2,"0",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(.5*(long1+long2),lat2,"25",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(long2,lat2,sprintf("%d km",r),'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')

end



function plotLVDescending(lookVector)

LX= lookVector(1);
LY= lookVector(2);
L= hypot(LX,LY);
LX= LX/L;
LY= LY/L;

x1= .82;
y1= .3;

scale= .075;

x= x1+ scale*[0 LX];
y= y1+ scale*[0 LY];

ar= annotation("arrow");
ar.Units= "normalized";
ar.X= x;
ar.Y= y;
ar.LineWidth= 4;
ar.HeadWidth= 20;
ar.HeadLength= 20;

text(.926,.15,'LOS','Units','normalized','FontSize',18, ...
    'FontName','Times','FontWeight','bold','VerticalAlignment','bottom', ...
    'HorizontalAlignment','center');

end


function [lat2,long2]= scaleBarkm(lat1,long1,r,h,N)

long2= long1+ (r/111)/cosd(lat1);
lat2= lat1+ h/111;

blackWhiteBar([long1 long2],[lat1 lat2],N)

end

function scaleBarMiles(lat1,long1,r,h,N)

r= r*1.609;

long2= long1+ (r/111)/cosd(lat1);
lat2= lat1- h/111;

blackWhiteBar([long1 long2],[lat1 lat2],N)


end


function blackWhiteBar(XLIM,YLIM,N)
x= linspace(XLIM(1),XLIM(2),N+1);
y= YLIM;

X= nan(4,N);
Y= nan(4,N);
for i= 1:N
    X(:,i)= x(i+ [0 1 1 0]);
    Y(:,i)= y([1 1 2 2]);
end

fill(X(:,1:2:end),Y(:,1:2:end),[0 0 0])
fill(X(:,2:2:end),Y(:,2:2:end),[1 1 1])

end






%%

CLIM= [-1 1]*500;
k= 3;
cmap= plt.colormap2('squirt','flip');

figure(2)
clf
set(gcf,'Position',[50    77   600   550])
[~,c]= plotImage2(Coseismic,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude,StationLatitude,150,GNSSParamMean(k,:),'filled',...
    "MarkerEdgeColor",'k')
hold on

set(gca,'Position',[.08 .2 .85 .75])
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Location= "southoutside";
c.Label.String= "Away"+ join(repmat(" ",14,1))+ ...
    "LOS Co-seismic Displacement (mm)"+ join(repmat(" ",14,1))+ "Towards";
% plotLVDescending(LookVector)
% scaleBar
yticklabels([])

exportgraphics(gcf,"Figures/smallmap_coseismic.pdf","ContentType","vector",'BackgroundColor','none')




%%

CLIM= [-1 1]*20;
k= 4;
cmap= plt.colormap2('squirt','flip');
postFactor= (1-exp(-1/1.8));

figure(3)
clf
set(gcf,'Position',[100    77   600   550])
[~,c]= plotImage2(PostSeismic*postFactor,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude,StationLatitude,100,GNSSParamMean(k,:)*postFactor,'filled',...
    "MarkerEdgeColor",'k')
hold on

set(gca,'Position',[.08 .2 .85 .75])
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Location= "southoutside";
c.Label.String= " Away"+ join(repmat(" ",9,1))+ ...
    "LOS Post-seismic Displacement @ 1yr (mm)"+ join(repmat(" ",10,1))+ "Towards";
plotLVDescending(LookVector)
scaleBar
yticklabels([])

exportgraphics(gcf,"Figures/smallmap_postseismic.pdf","ContentType","vector",'BackgroundColor','none')



%%

% ylabel(sprintf('  Away %s%s%sTowards',repmat(' ',Nspace,1),...
%     "LOS Displacement (mm)",repmat(' ',Nspace,1)))


%% 
