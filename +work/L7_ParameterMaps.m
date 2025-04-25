%% Parameter Maps


load input.mat workdir datadir

ParamFile= fullfile(workdir,"L6output.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";


%% Load

load(GNSSFile,"GNSSDate","GNSSReferenced","ID","StationLatitude","StationLongitude")
GNSS= GNSSReferenced;

B= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],1.8);

[GNSSParamMean,~,~,GNSSRMSE]= utils.fitParams(GNSS,B);


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
set(gcf,'Position',[1    77   900   720])
[h,c]= plotImage2(Velocity,illuminationImage,GridLong,GridLat,[],CLIM);
hold on
scatter(StationLongitude,StationLatitude,100,GNSSParamMean(k,:),'filled',...
    "MarkerEdgeColor",'k')
hold on
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Label.String= "Away"+ join(repmat(" ",22,1))+ "LOS Velocity (mm/yr)"+ join(repmat(" ",22,1))+ "Towards";
Ileft= ID == "P617" | ID == "HAR7" | ID == "TOWG" | ID == "COSO";
text(StationLongitude(~Ileft)+.02,StationLatitude(~Ileft),ID(~Ileft),"FontSize",16,"FontName","Times")
text(StationLongitude(Ileft)-.02,StationLatitude(Ileft),ID(Ileft), ...
    "FontSize",16,"FontName","Times",'HorizontalAlignment','right')
plotLVDescending(LookVector)
scaleBar

% exportgraphics(gcf,"Figures/map_velocity.pdf","ContentType","vector")


[GX,GY]= gradient(Velocity);

figure(10)
plotImage2(GX,illuminationImage,GridLong,GridLat,[],[-1 1]*.5);



function scaleBar

r= 20;
long1= -116.82;
lat1= 35.02;

[lat2,long2]= scaleBarkm(lat1,long1,r,1.5,4);

text(long1,lat2,"0",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(.5*(long1+long2),lat2,"10",'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')
text(long2,lat2,sprintf("    %d km",r),'VerticalAlignment','bottom','FontSize',16,'FontName',"Times",'HorizontalAlignment','center')

end



function plotLVDescending(lookVector)

LX= lookVector(1);
LY= lookVector(2);
L= hypot(LX,LY);
LX= LX/L;
LY= LY/L;

x1= .781;
y1= .2;

scale= .06;

x= x1+ scale*[0 LX];
y= y1+ scale*[0 LY];

ar= annotation("arrow");
ar.Units= "normalized";
ar.X= x;
ar.Y= y;
ar.LineWidth= 4;
ar.HeadWidth= 20;
ar.HeadLength= 20;

text(.923,.093,'LOS','Units','normalized','FontSize',18, ...
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
set(gcf,'Position',[50    77   900   720])
[h,c]= plotImage2(Coseismic,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
scatter(StationLongitude,StationLatitude,100,GNSSParamMean(k,:),'filled',...
    "MarkerEdgeColor",'k')
hold on
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Label.String= "Away"+ join(repmat(" ",18,1))+ "LOS Co-seismic Displacement (mm)"+ join(repmat(" ",18,1))+ "Towards";
Ileft= ID == "P617" | ID == "HAR7" | ID == "TOWG" | ID == "P463";
text(StationLongitude(~Ileft)+.02,StationLatitude(~Ileft),ID(~Ileft),"FontSize",16,"FontName","Times")
text(StationLongitude(Ileft)-.02,StationLatitude(Ileft),ID(Ileft), ...
    "FontSize",16,"FontName","Times",'HorizontalAlignment','right')
plotLVDescending(LookVector)
scaleBar

% exportgraphics(gcf,"Figures/map_coseismic.pdf","ContentType","vector")


[GX,GY]= gradient(Coseismic);

figure(11)
plotImage2(GY,illuminationImage,GridLong,GridLat,[],[-1 1]*10);

%%

CLIM= [-1 1]*20;
k= 4;
cmap= plt.colormap2('squirt','flip');
postFactor= (1-exp(-1/1.8));

LatEQ= 35.72;
LongEQ= -117.62;

[LONG,LAT]= meshgrid(GridLong,GridLat);

R= 111*distance(LatEQ,LongEQ,LAT,LONG);


figure(3)
clf
set(gcf,'Position',[100    77   900   720])
[~,c]= plotImage2(PostSeismic*postFactor,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
scatter(StationLongitude,StationLatitude,100,GNSSParamMean(k,:)*postFactor,'filled',...
    "MarkerEdgeColor",'k')
% contour(GridLong,GridLat,abs(PostSeismic*postFactor),[5 5],'k')
% contour(GridLong,GridLat,R,[0 0]+ 60,'k')
hold on
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Label.String= "Away"+ join(repmat(" ",13,1))+ "LOS Post-seismic Displacement @ 1yr (mm)"+ join(repmat(" ",13,1))+ "Towards";
Ileft= ID == "P617" | ID == "HAR7" | ID == "TOWG" | ID == "P463";
text(StationLongitude(~Ileft)+.02,StationLatitude(~Ileft),ID(~Ileft),"FontSize",16,"FontName","Times")
text(StationLongitude(Ileft)-.02,StationLatitude(Ileft),ID(Ileft), ...
    "FontSize",16,"FontName","Times",'HorizontalAlignment','right')
plotLVDescending(LookVector)
scaleBar

% exportgraphics(gcf,"Figures/map_postseismic.pdf","ContentType","vector")



[GX,GY]= gradient(PostSeismic*postFactor);

figure(12)
plotImage2(GX,illuminationImage,GridLong,GridLat,[],[-1 1]*.5);


%%

GNSSFilteredResidualFile= fullfile(workdir,"L5_StochasticCovariance");

load(GNSSFilteredResidualFile,"GNSSDate","FilteredResidual")

GNSSRMSE= rms(FilteredResidual,'omitmissing');

CLIM= [0 1]*1;
cmap= plt.colormap2('sunset');

figure(4)
clf
set(gcf,'Position',[100    77   900   720])
[~,c]= plotImage2(RMSE,illuminationImage,GridLong,GridLat,cmap,CLIM);
hold on
scatter(StationLongitude,StationLatitude,100,GNSSRMSE,'filled',...
    "MarkerEdgeColor",'k')
% contour(GridLong,GridLat,abs(PostSeismic*postFactor),[5 5],'k')
% contour(GridLong,GridLat,R,[0 0]+ 60,'k')
hold on
daspect([1 cosd(mean(GridLat)) 1])
setOptions
c.Label.String= "Displacement RMSE (mm)";
Ileft= ID == "P617" | ID == "HAR7" | ID == "TOWG" | ID == "P463";
text(StationLongitude(~Ileft)+.02,StationLatitude(~Ileft),ID(~Ileft),"FontSize",16,"FontName","Times")
text(StationLongitude(Ileft)-.02,StationLatitude(Ileft),ID(Ileft), ...
    "FontSize",16,"FontName","Times",'HorizontalAlignment','right')
plotLVDescending(LookVector)
scaleBar

exportgraphics(gcf,"Figures/map_residual.pdf","ContentType","vector")



%%

% ylabel(sprintf('  Away %s%s%sTowards',repmat(' ',Nspace,1),...
%     "LOS Displacement (mm)",repmat(' ',Nspace,1)))


%% 
