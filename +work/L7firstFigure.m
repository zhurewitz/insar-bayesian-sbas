

load input.mat workdir

InterferogramFile= fullfile(workdir,"L2referenced.h5");
ColocatedFile= fullfile(workdir,"L6_ColocatedPosterior.mat");
ColocatedFile2= fullfile(workdir,"L4_ColocatedInSAR.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";

%%


load(ColocatedFile,"ColocatedPosterior","Date")
load(ColocatedFile2,"ColocatedTimeseries","PostingDate")
load(CovFile,"PosteriorCovariance")
load(GNSSFile,"GNSSDate","GNSSReferenced",'ID','StationLatitude','StationLongitude')
GNSS= GNSSReferenced;

SigmaUncertainty= sqrt(diag(PosteriorCovariance));
Nstations= length(ID);

load Elevation.mat Elevation
illuminationImage= backgroundIllumination2(Elevation);

load faults.mat

load EQsequence.mat
EQLat= T.latitude(T.mag > 6);
EQLong= T.longitude(T.mag > 6);


%%

StationID= "P593";
I= ID == StationID;


k= 650; %800,1100,951,1150,650,660

[GridLong,GridLat,DatePairs]= d3.readXYZ(InterferogramFile);
Interferogram= d3.readPage(InterferogramFile,k); 

DatePairs(k,:)



col= [.2 .6 .2];


J= PostingDate == DatePairs(k,1) | PostingDate == DatePairs(k,2);

%%

CLIM= [-1 1]*40;

figure(2)
set(gcf,'Position',[1   242   590   555])

clf
axes('Position',[5 30 90 65]/100)
[~,c]= plotImage2(Interferogram,illuminationImage,GridLong,GridLat,[],CLIM);
% delete(c)
hold on
% plot(FaultLong,FaultLat,'--',"Color",[0 0 0]+.5)
scatter(StationLongitude(I),StationLatitude(I),100,'k','filled',...
    "MarkerEdgeColor",'k','Marker','^')
% scatter(EQLong,EQLat,150,'yellow','filled','pentagram','MarkerEdgeColor','k')
hold on
daspect([1 cosd(mean(GridLat)) 1])
setOptions

c.Position= [74 32 4 10]/100;
c.Ticks= [-40 0 40];
c.Label.String= "LOS (mm)";
c.TickLabels= ["-40" "  0" " 40"];

% c.Label.String= "LOS Interferometric Displacement (mm)";


YLIM= [-20 40];

axes('Position',[13.5 5 72.8 20]/100)
hold on
plot(PostingDate,ColocatedTimeseries(:,I),'k')
plot(DatePairs(k,:),ColocatedTimeseries(J,I),'k','LineWidth',3)
scatter(DatePairs(k,:),ColocatedTimeseries(J,I),'k','filled')
% plotUncertainty(Date,ColocatedPosterior(:,I),2*SigmaUncertainty,[],.3)
% plot(GNSSDate,GNSSReferenced(:,I),'Color',[.5,0,.5,.2])
% plot(datetime(2019,7,5)+[0 0],YLIM,'--','Color',[.8 .3 .1],'LineWidth',2)

hold on
% plot(GNSSDate,GNSS(:,I),'Color',[0 0 0 .5])
% title(ID(I))
setOptions
ylim(YLIM)
box on
% xlim(PostingDate([50 end-100]))
xlim([datetime(2015,1,1) datetime(2025,1,1)])

ylabel("LOS (mm)")
legend("InSAR Timeseries","Interferogram",'Location','northwest')
% legend("InSAR Timeseries","Interferogram","","Earthquake Date",'Location','northwest')

% ylabel("LOS Interferometric Displacement (mm)")

exportgraphics(gcf,'Figures/firstFigure.pdf','ContentType','vector','BackgroundColor','none')

