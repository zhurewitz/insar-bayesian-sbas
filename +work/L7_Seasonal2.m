

load input.mat workdir

ColocatedFile= fullfile(workdir,"L6_ColocatedPosterior.mat");
ColocatedFile2= fullfile(workdir,"L4_ColocatedInSAR.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";
GNSSFile2= "GNSS3LOS_cov.mat";

%%

load(ColocatedFile,"ColocatedPosterior","Date")
load(ColocatedFile2,"ColocatedTimeseries","PostingDate")
load(CovFile,"PosteriorCovariance")
load(GNSSFile,"GNSSDate","GNSSReferenced",'ID')
load(GNSSFile2,"GNSSLOS71Uncertainty")

Nstations= length(ID);

Ngnss= length(GNSSDate);
Nposting= length(PostingDate);
Ndate= length(Date);

GNSS= nan(Ngnss,Nstations);
SBAS= nan(Nposting,Nstations);
INSAR= nan(Ndate,Nstations);

for sta= 1:Nstations
    x= GNSSReferenced(:,sta);
    A= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],1.8);
    [~,~,Residual]= utils.fitParams(x,A);
    GNSS(:,sta)= Residual;
    
    x= ColocatedTimeseries(:,sta);
    A= utils.parameterMatrix2(PostingDate,1,1,1,0,0,[],1.8);
    [~,~,Residual]= utils.fitParams(x,A);
    SBAS(:,sta)= Residual;

    x= ColocatedPosterior(:,sta);
    A= utils.parameterMatrix2(Date,1,1,1,0,0,[],1.8);
    [~,~,Residual]= utils.fitParams(x,A);
    INSAR(:,sta)= Residual;
end


GNSSFit= nan(Ndate,Nstations);
SBASFit= nan(Ndate,Nstations);
INSARFit= nan(Ndate,Nstations);

A0= utils.parameterMatrix2(Date,0,0,0,1,0);
for sta= 1:Nstations
    x= GNSS(:,sta);
    A= utils.parameterMatrix2(GNSSDate,0,0,0,1,0);
    p= utils.fitParams(x,A);
    GNSSFit(:,sta)= A0*p;
    
    x= SBAS(:,sta);
    A= utils.parameterMatrix2(PostingDate,0,0,0,1,0);
    p= utils.fitParams(x,A);
    SBASFit(:,sta)= A0*p;

    x= INSAR(:,sta);
    A= utils.parameterMatrix2(Date,0,0,0,1,0);
    p= utils.fitParams(x,A);
    INSARFit(:,sta)= A0*p;
end



%%

sta= ID == "GOLD";

figure(1)
% set(gcf,'Position',[1 500 1300 300])
clf

col= [.8 .5 .2];

hold on
scatter(GNSSDate,GNSS(:,sta),10,[0 0 0]+.5,'filled','MarkerFaceAlpha',1)
plot(PostingDate,SBAS(:,sta),'Color',col,'LineWidth',1)
plot(Date,SBASFit(:,sta),'Color',col,"LineWidth",5)
plot(Date,GNSSFit(:,sta),'Color','k',"LineWidth",5)


box on
setOptions
xlim(datetime([2015 2025],1,1))
grid on
xticks(datetime(2015:5:2025,1,1))
set(gca,'FontSize',14)

text(.98,.98,IDq,"FontSize",14,'FontName','Times','Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w')


YLIM= [-20 20];
ylim(YLIM)
yticks(YLIM(1):20:YLIM(2))
% text(4/100,95/100, 'd','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')
% legend("SBAS","","GNSS","","","","InSAR","GNSS Fit",'Location','southeast')


% exportgraphics(gcf,'Figures/timeseries.pdf','ContentType','vector','BackgroundColor','none')





%%

offset= 200+ -(0:Nstations-1)*7;

figure(2)
clf
hold on
plot(Date,SBASFit+offset,'Color',col,"LineWidth",2)
plot(Date,GNSSFit+offset,'Color','k',"LineWidth",2)
xlim(datetime([2015 2025],1,1))
ylim([0 205])
yticks(0:50:200)
setOptions
xticks(datetime(2015:2025,1,1))
xticklabels(["2015" "" "" "" "" "2020" "" "" "" "" "2025"])
xtickangle(0)
box on
text(datetime(2025,2,1)+ zeros(1,Nstations), offset, ID, ...
    'FontSize',14,'FontName','Times')
ylabel("Seasonal Displacement (mm)")
legend(["SBAS",repmat("",1,Nstations-1),"GNSS"])