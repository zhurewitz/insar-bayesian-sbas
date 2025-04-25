

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
Ndate= length(Date);

AMPGNSS= nan(Nstations,1);
AMPSBAS= nan(Nstations,1);
AMPBINSAR= nan(Nstations,1);
AMPSTDBINSAR= nan(Nstations,1);
PHASEGNSS= nan(Nstations,1);
PHASESBAS= nan(Nstations,1);
PHASEBINSAR= nan(Nstations,1);
for sta= 1:Nstations
    GNSS= GNSSReferenced(:,sta);

    SBAS= ColocatedTimeseries(:,sta);

    BInSAR= ColocatedPosterior(:,sta);

    A= utils.parameterMatrix2(GNSSDate,1,1,1,1,0,[],1.8);
    p= utils.fitParams(GNSS,A);
    AMPGNSS(sta)= hypot(p(5),p(6));
    PHASEGNSS(sta)= mod(atan2(p(6),p(5))*365/(2*pi),365);

    A= utils.parameterMatrix2(PostingDate,1,1,1,1,0,[],1.8);
    p= utils.fitParams(SBAS,A);
    AMPSBAS(sta)= hypot(p(5),p(6));
    PHASESBAS(sta)= mod(atan2(p(6),p(5))*365/(2*pi),365);
    

    A= utils.parameterMatrix2(Date,1,1,1,1,0,[],1.8);
    p= utils.fitParams(BInSAR+ matrixsqrt(PosteriorCovariance,180)*randn(180,1e4),A);
    AMPBINSAR(sta)= mean(hypot(p(5,:),p(6,:)),2);
    AMPSTDBINSAR(sta)= std(hypot(p(5,:),p(6,:)),[],2);
    PHASEBINSAR(sta)= mod(angle(mean(p(5,:) + 1i*p(6,:)))*365/(2*pi),365);
end

AMPBINSAR(AMPBINSAR == 0)= nan;



IDq= "GOLD";
sta= ID == IDq;

GNSS= GNSSReferenced(:,sta);
GNSSu= GNSSLOS71Uncertainty(:,sta);

SBAS= ColocatedTimeseries(:,sta);

% BInSAR= ColocatedPosterior(:,sta);
% BInSARu= sqrt(diag(PosteriorCovariance));

AGNSS= utils.parameterMatrix2(GNSSDate,1,1,1,1,0,[],1.8);
[paramsGNSS,GNSSBestFit]= utils.fitParams(GNSS,AGNSS);

ASBAS= utils.parameterMatrix2(PostingDate,1,1,1,1,0,[],1.8);
[paramsSBAS,SBASBestFit]= utils.fitParams(SBAS,ASBAS);


%%

figure(1)
% set(gcf,'Position',[1 500 1300 300])
clf

col= [.8 .5 .2];

hold on
plot(PostingDate,SBAS,'Color',col)
plt.errorbar2(GNSSDate,GNSS,GNSSu,[],.5,[0 0 0],.3,4,1)
% plotUncertainty(Date,BInSAR,2*BInSARu,col,.5,0)
hold on

% plot(Date,BInSAR+ [-2 2].*BInSARu,'-','Color',col, ...
%     "LineWidth",1)
% plot(Date,BInSAR,'-','Color',col, ...
%     "LineWidth",3)
plot(GNSSDate,GNSSBestFit,'-','Color',[.2 0 .8], ...
    "LineWidth",3)
plot(PostingDate,SBASBestFit,'-','Color',col, ...
    "LineWidth",3)

box on
setOptions
xlim(datetime([2015 2025],1,1))
grid on
xticks(datetime(2015:5:2025,1,1))
set(gca,'FontSize',14)

text(.98,.98,IDq,"FontSize",14,'FontName','Times','Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w')



ylim([-20 60])
yticks(-20:20:60)
% text(4/100,95/100, 'd','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')
% legend("SBAS","","GNSS","","","","InSAR","GNSS Fit",'Location','southeast')


% exportgraphics(gcf,'Figures/timeseries.pdf','ContentType','vector','BackgroundColor','none')





%%

figure(2)
clf
scatter(AMPGNSS,AMPSBAS,100,'k','filled')
% text(AMPGNSS+.1,AMPSBAS+.1,ID)
hold on
scatter(AMPGNSS,AMPBINSAR,100,'b','filled')
text(AMPGNSS+.1,AMPBINSAR+.1,ID)
setOptions
% axis equal
xlim([0 5])
ylim([0 5])

figure(3)
clf
scatter(PHASEGNSS,PHASESBAS,100,'k','filled')
hold on
scatter(PHASEGNSS,PHASEBINSAR,100,'b','filled')
setOptions
axis equal

[~,~,~,Statistics]= simpleLinearRegression(PHASEGNSS,PHASESBAS);
Statistics.Rsquared


figure(3)
clf
scatter(PHASEGNSS,PHASESBAS,100,'k','filled')
hold on
scatter(PHASEGNSS,PHASEBINSAR,100,'b','filled')
setOptions
axis equal

[~,~,~,Statistics]= simpleLinearRegression(PHASEGNSS,PHASESBAS);
Statistics.Rsquared





figure(4)
polarhistogram([PHASEGNSS PHASEGNSS+365/2]/365*2*pi,20)

figure(5)
polarhistogram([PHASESBAS PHASESBAS+365/2]/365*2*pi,20)

figure(6)
i= AMPGNSS > .5;
polarhistogram([PHASEGNSS(i) PHASEGNSS(i)+365/2]/365*2*pi,20)
% 
% m= mean(exp(1i*mod(PHASEGNSS,365/2)/365*2*pi));
% R= abs(m);
% 1-R
% 
% m= mean(exp(1i*mod(PHASESBAS,365/2)/365*2*pi));
% R= abs(m);
% 1-R
% 
% m= mean(exp(1i*mod(PHASEGNSS(i),365/2)/365*2*pi));
% R= abs(m);
% 1-R

