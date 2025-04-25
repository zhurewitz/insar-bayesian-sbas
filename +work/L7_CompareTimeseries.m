

load input.mat workdir

ColocatedFile= fullfile(workdir,"L6_ColocatedPosterior.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";

%%

load(ColocatedFile,"ColocatedPosterior","Date")
load(CovFile,"PosteriorCovariance")
load(GNSSFile,"GNSSDate","GNSSReferenced",'ID')
GNSS= GNSSReferenced;

SigmaUncertainty= sqrt(diag(PosteriorCovariance));
Nstations= length(ID);

figure(1)
clf
tiledlayoutcompact("",[],[],false)
for i= 1:Nstations
    nexttile
    plot(GNSSDate,GNSS(:,i),'Color',[0 0 0 .2])
    hold on
    plotUncertainty(Date,ColocatedPosterior(:,i),2*SigmaUncertainty,[],.3)
    hold off
    title(ID(i))
    setOptions
end

