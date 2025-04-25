%% Parameter Maps


load input.mat workdir datadir

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


FIGPOS= [1    300   600   500];
AXISPOS= [8 9 88 85]/100;



%%

CLIM= [-1 1]*5;
k= 1;
cmap= colormap2('redblue');
DATA= Velocity;

figure(1)
clf
set(gcf,'Position',FIGPOS)
[~,c]= plotImage2(DATA,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude,StationLatitude,150,GNSSParamMean(k,:),'filled',...
    "MarkerEdgeColor",'k')
% contour(GridLong,GridLat,abs(DATA),[0 0]+ 0.79,'k')

set(gca,'Position',AXISPOS)
daspect([1 cosd(mean(GridLat)) 1])
setOptions
delete(c)
xticklabels([])
textID(ID,StationLongitude,StationLatitude)

savePDF("Figures/smallmapvert_velocity.pdf")









function textID(ID,StationLongitude,StationLatitude)

Ileft= ID == "P617" | ID == "TOWG" | ID == "P596" | ID == "LNMT";
Iur= ID == "P462";
Iul= ID == "HAR7";
Ill= ID == "COSO";
Id= ID == "P463";
Iright= ~Ileft & ~Iur & ~Iul & ~Id & ~Ill;

text(StationLongitude(Iright)+.03,StationLatitude(Iright),ID(Iright), ...
    "FontSize",14,"FontName","Times")
text(StationLongitude(Ileft)-.03,StationLatitude(Ileft),ID(Ileft), ...
    "FontSize",14,"FontName","Times",'HorizontalAlignment','right')
text(StationLongitude(Iur)+.02,StationLatitude(Iur)+.03,ID(Iur), ...
    "FontSize",14,"FontName","Times")
text(StationLongitude(Iul)-.02,StationLatitude(Iul)+.02,ID(Iul), ...
    "FontSize",14,"FontName","Times",'HorizontalAlignment','right')
text(StationLongitude(Id)+.01,StationLatitude(Id)-.02,ID(Id), ...
    "FontSize",14,"FontName","Times",'HorizontalAlignment','center', ...
    'VerticalAlignment','top')
text(StationLongitude(Ill)+.02,StationLatitude(Ill)-.02,ID(Ill), ...
    "FontSize",14,"FontName","Times",'HorizontalAlignment','right', ...
    'VerticalAlignment','top')

end



function scaleBar

r= 50;
long1= -117.15;
lat1= 35.02;

[lat2,long2]= scaleBarkm(lat1,long1,r,2,10);

text(long1,lat2,"0",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(.5*(long1+long2),lat2,"25",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(long2,lat2,sprintf("%d km",r),'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')

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

figure(4)
clf 
set(gcf,'Position',FIGPOS)
set(gca,'Position',AXISPOS)
axis off
c= colorbar;
CPOS= [16 71 3 20]/100;
c.Position= CPOS;
c.Label.String= "LOS Vel. (mm/yr)";
setOptions
colormap2('redblue','Range',CLIM)
savePDF("Figures/smallmapvert_velocityColorbar.pdf")



%%


CLIM= [-1 1]*500;
k= 3;
cmap= plt.colormap2('squirt','flip');
DATA= Coseismic;
GNSSDATA= GNSSParamMean(k,:);

figure(2)
clf
set(gcf,'Position',FIGPOS)
[~,c]= plotImage2(DATA,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude,StationLatitude,150,GNSSDATA,'filled',...
    "MarkerEdgeColor",'k')
hold on
% contour(GridLong,GridLat,abs(DATA),[0 0]+ 3*2.4,'k')

set(gca,'Position',AXISPOS)
daspect([1 cosd(mean(GridLat)) 1])
setOptions
xticklabels([])
delete(c)
textID(ID,StationLongitude,StationLatitude)

filename= "Figures/smallmapvert_coseismic.pdf";
savePDF(filename)

%%

figure(5)
clf 
set(gcf,'Position',FIGPOS)
set(gca,'Position',AXISPOS)
axis off
c= colorbar;
CPOS= [16 71 3 20]/100;
c.Position= CPOS;
c.Label.String= "LOS Co.Seis. (mm)";
setOptions
colormap(cmap)
clim(CLIM)
savePDF("Figures/smallmapvert_coseismicColorbar.pdf")


%%

load eqDistance.mat eqlong eqlat


CLIM= [-1 1]*40;
k= 4;
cmap= plt.colormap2('squirt','flip');
DATA= PostSeismic;
GNSSDATA= GNSSParamMean(k,:);

figure(3)
clf
set(gcf,'Position',FIGPOS)
[~,c]= plotImage2(DATA,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
contour(GridLong(1:4:end),GridLat(1:4:end),abs(DATA(1:4:end,1:4:end)),5.2*[2 2],'k')
th= linspace(0,360,100);
[clat,clong]= reckon(eqlat,eqlong,60/111.2,th);
plot(clong,clat,'k--')
scatter(StationLongitude,StationLatitude,100,GNSSDATA,'filled',...
    "MarkerEdgeColor",'k')
hold on

set(gca,'Position',AXISPOS)
daspect([1 cosd(mean(GridLat)) 1])
setOptions
delete(c)
plotLVDescending(LookVector)
scaleBar
textID(ID,StationLongitude,StationLatitude)

filename= "Figures/smallmapvert_postseismic.pdf";
savePDF(filename)


%%
figure(6)
clf 
set(gcf,'Position',FIGPOS)
set(gca,'Position',AXISPOS)
axis off
c= colorbar;
CPOS= [16 71 3 20]/100;
c.Position= CPOS;
c.Label.String= "LOS Post.Seis. (mm)";
c.Ticks= -40:40:40;
setOptions
colormap(cmap)
clim(CLIM)
savePDF("Figures/smallmapvert_postseismicColorbar.pdf")



function plotLVDescending(lookVector)

LX= lookVector(1);
LY= lookVector(2);
L= hypot(LX,LY);
LX= LX/L;
LY= LY/L;

x1= .835;
y1= .186;

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

text(.917,.12,'LOS','Units','normalized','FontSize',18, ...
    'FontName','Times','FontWeight','bold','VerticalAlignment','bottom', ...
    'HorizontalAlignment','center');

end