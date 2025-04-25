

load input.mat workdir

ColocatedFile= fullfile(workdir,"L4_ColocatedInSAR.mat");
GNSSFile= "GNSS4LOSdemean.mat";


%%

load(ColocatedFile)
load(GNSSFile)

%%

IDexclude= "P595";
Ikeep= ID ~= IDexclude;

[IntersectDate,ia,ib]= intersect(PostingDate,GNSSDate);


ResidualTimeseries= ColocatedTimeseries(ia,Ikeep)- GNSSReferenced(ib,Ikeep);
STD= rms(ResidualTimeseries,2,'omitmissing');

t= years(IntersectDate- datetime(2015,1,1));
A= [ones(length(t),1) cos(2*pi*t) sin(2*pi*t)];

[param,BestFit]= utils.fitParams(STD,A);

Date2= linspace(datetime(2015,1,1),datetime(2025,1,1),200)';
t2= years(Date2- datetime(2015,1,1));
A2= [ones(length(t2),1) cos(2*pi*t2) sin(2*pi*t2)];

ErrorModel= A2*param;


figure(1)
tiledlayoutcompact
plot(IntersectDate,ResidualTimeseries, ...
    'Color',[0 0 0 .3])
setOptions

nexttile
plot(IntersectDate,STD, ...
    'Color',[0 0 0 .3])
hold on
plot(IntersectDate,BestFit)
setOptions

nexttile
histogram(ResidualTimeseries/std(ResidualTimeseries,[],'all','omitmissing'))
hold on
histogram(ResidualTimeseries./BestFit)
setOptions

monthOrder = {'January','February','March','April','May','June','July', ...
    'August','September','October','November','December'};
monthOrder2 = {'Jan','Feb','Mar','Apr','May','Jun','Jul', ...
    'Aug','Sep','Oct','Nov','Dec'};

nexttile
h= boxchart(categorical(month(IntersectDate,'shortname'),monthOrder2),STD);
h.MarkerStyle= '.';
setOptions
ylim([0 25])


%%

Nstations= length(ID);

sta1= ID == "P594";
sta2= ID == "RAMT";

figure(2)
set(gcf,'Position',[1   328   518   469])
clf
% axes("Position",[10 65 38 30]/100)
tiledlayoutcompact("",2,2)
hold on
plot(PostingDate,ColocatedTimeseries(:,sta1),'LineWidth',.5,'Color',[.2 .6 .8])
scatter(GNSSDate,GNSSReferenced(:,sta),2,'k','filled','MarkerFaceAlpha',.4)

setOptions
box on
% ylim([-15 35])
xlim(datetime([2015 2025],1,1))
xticks(datetime(2015:5:2025,1,1))
ylabel("LOS (mm)")
set(gca,'FontSize',14)


% axes("Position",[100-38-3 65 38 30]/100)
nexttile
plot(IntersectDate,ResidualTimeseries(:,sta1),'LineWidth',1,'Color',[.2 .6 .8])
ylabel("Residual (mm)")
ylim([-1 1]*40)
xlim(datetime([2015 2025],1,1))
xticks(datetime(2015:5:2025,1,1))
setOptions
set(gca,'FontSize',14)

% axes("Position",[10 35 100-10-3 25]/100)
nexttile(3,[1 2])
hold on
plot(IntersectDate,ResidualTimeseries,'-','Color',[0 0 0 .3])
% plot(IntersectDate,ResidualTimeseries(:,sta1),'LineWidth',1.5,'Color',[0 0 1])
areaBetween(Date2,-ErrorModel,ErrorModel,[],.1)
plot(Date2,ErrorModel.*[-1 1],'--','LineWidth',2,'Color',[.7 0 0 ])
setOptions
box on
ylim([-1 1]*40)
xlim(datetime([2015 2025],1,1))
ylabel("Residual (mm)")
set(gca,'FontSize',14)

exportgraphics(gcf,'Figures/residualTrop.pdf','ContentType','vector','BackgroundColor','none')
