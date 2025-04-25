

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
GNSS= GNSSReferenced;

SigmaUncertainty= sqrt(diag(PosteriorCovariance));
Nstations= length(ID);


AGNSS= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],1.8);

Ngnss= length(GNSSDate);
Nsamples= 10000;


GNSSBestFit= nan(Ngnss,Nstations);
GNSSParameterFitUncertainty= nan(Ngnss,Nstations);
for sta= 1:Nstations
    GNSSSamples= GNSS(:,sta)+ GNSSLOS71Uncertainty(:,sta).*randn(Ngnss,Nsamples);
    
    [params,BestFit]= utils.fitParams(GNSSSamples,AGNSS);
    
    GNSSBestFit(:,sta)= mean(BestFit,2);
    GNSSParameterFitUncertainty(:,sta)= std(BestFit,[],2);
    
    fprintf("Station %s complete\n",ID(sta))
end







%%






figure(1)
set(gcf,'Position',[1 500 1300 300])
clf
tiledlayoutcompact("",1,4)
sta= "P594";
plotTS(GNSSDate,GNSS,GNSSLOS71Uncertainty,GNSSBestFit,Date,ColocatedPosterior,SigmaUncertainty,PostingDate,ColocatedTimeseries,ID,sta)
ylim([-40 120])
ylabel("LOS Displacement (mm)")
text(4/100,95/100, 'a','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')

nexttile
sta= "P616";
plotTS(GNSSDate,GNSS,GNSSLOS71Uncertainty,GNSSBestFit,Date,ColocatedPosterior,SigmaUncertainty,PostingDate,ColocatedTimeseries,ID,sta)
ylim([-60 20])
yticks(-60:20:20)
text(4/100,95/100, 'b','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')

nexttile
sta= "DS13";
plotTS(GNSSDate,GNSS,GNSSLOS71Uncertainty,GNSSBestFit,Date,ColocatedPosterior,SigmaUncertainty,PostingDate,ColocatedTimeseries,ID,sta)
ylim([-20 60])
yticks(-20:20:60)
text(4/100,95/100, 'c','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')

nexttile
sta= "P462";
plotTS(GNSSDate,GNSS,GNSSLOS71Uncertainty,GNSSBestFit,Date,ColocatedPosterior,SigmaUncertainty,PostingDate,ColocatedTimeseries,ID,sta)
ylim([-20 60])
yticks(-20:20:60)
text(4/100,95/100, 'd','FontSize',20,'FontName','Times','FontWeight','bold','Units','normalized')
legend("SBAS","","GNSS","","","","InSAR","GNSS Fit",'Location','southeast')


exportgraphics(gcf,'Figures/timeseries.pdf','ContentType','vector','BackgroundColor','none')






function plotTS(GNSSDate,GNSS,GNSSLOS71Uncertainty,GNSSBestFit,Date,ColocatedPosterior,SigmaUncertainty,PostingDate,ColocatedTimeseries,ID,sta)

i= ID == sta;

col= [.8 .5 .2];

hold on
plot(PostingDate,ColocatedTimeseries(:,i),'Color',col)
plt.errorbar2(GNSSDate,GNSS(:,i),GNSSLOS71Uncertainty(:,i),[],.5,[0 0 0],.3,4,1)
plotUncertainty(Date,ColocatedPosterior(:,i),2*SigmaUncertainty,col,.5,0)
hold on

plot(Date,ColocatedPosterior(:,i)+ [-2 2].*SigmaUncertainty,'-','Color',col, ...
    "LineWidth",1)
plot(Date,ColocatedPosterior(:,i),'-','Color',col, ...
    "LineWidth",3)
plot(GNSSDate,GNSSBestFit(:,i),'-','Color',[.2 0 .8], ...
    "LineWidth",3)

box on
setOptions
xlim(datetime([2015 2025],1,1))
grid on
xticks(datetime(2015:5:2025,1,1))
set(gca,'FontSize',14)

text(.98,.98,sta,"FontSize",14,'FontName','Times','Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','top','BackgroundColor','w')

end
