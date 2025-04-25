
load input.mat workdir

ColocatedFile= fullfile(workdir,"L6_ColocatedPosterior.mat");
CovFile= fullfile(workdir,"L5output.mat");
GNSSFile= "GNSS4LOSdemean.mat";


%%

load(ColocatedFile,"ColocatedPosterior","Date")
load(CovFile,"PosteriorCovariance")
load(GNSSFile,"GNSSDate","GNSSReferenced","ID")
load("GNSS3LOS_cov.mat","GNSSLOS71Uncertainty")
GNSS= GNSSReferenced;
GNSSu= GNSSLOS71Uncertainty;


Nstations= length(ID);
Ngnss= length(GNSSDate);
Ndate= length(Date);

Iempty= all(isnan(ColocatedPosterior));
IDempty= ID(Iempty);

A= utils.parameterMatrix2(Date,1,1,1,0,0,[],1.8);
B= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],1.8);

Nparams= width(A);

iA= (A'*A)\A';

InSARParamMean= iA*ColocatedPosterior;
InSARParamCovariance= iA*PosteriorCovariance*iA';
InSARSigmaUncertainty= sqrt(diag(InSARParamCovariance));

GNSSParamMean= nan(Nparams,Nstations);
GNSSParamStd= nan(Nparams,Nstations);

Nsamples= 10000;
for i= 1:Nstations
    samples= GNSS(:,i)+ GNSSu(:,i).*randn(Ngnss,Nsamples);
    
    p= utils.fitParams(samples,B);
    
    GNSSParamMean(:,i)= mean(p,2,'omitmissing');
    GNSSParamStd(:,i)= std(p,[],2,'omitmissing');
    
    fprintf("Station %s\n",ID(i))
end


FIGPOS= [1    300   600   500];
AXISPOS= [8 9 88 85]/100;



%% Velocity

fignum= 1;
k= 1;
Label= "LOS Velocity (mm/yr)";
LIM= [-1 1]*4.5;
IDexclude= [IDempty; ""];

[IDkeep,Ikeep]= setdiff(ID,IDexclude);
IDlabel= IDkeep;
IDlabel= ["TOWG" "CCCC" "COSO" "P616" "DS13" "P594" "P462"];

Xquery= linspace(LIM(1),LIM(2),100);
x= GNSSParamMean(k,Ikeep)';
y= InSARParamMean(k,Ikeep)';
ux= GNSSParamStd(k,Ikeep)';
uy= InSARSigmaUncertainty(k);
[Mean,Uncertainty,~,Statistics]= ...
    simpleLinearRegressionMonteCarlo(x,y,ux,uy,Xquery);
[~,Ilabel]= intersect(IDkeep,IDlabel);
[~,pvalue]= kstest((y-x)./hypot(ux,uy));

figure(fignum)
set(gcf,"Position",FIGPOS)
set(gca,"Position",AXISPOS)
plot(LIM,LIM,'k--')
hold on
errorbar3(x,y,2*ux,2*uy,1,[0 0 0 ],.4,30,1)
plotUncertainty(Xquery,Mean,Uncertainty,[.8 0 0])
hold off
setOptions
text(x(Ilabel)+.12,y(Ilabel),IDkeep(Ilabel),'FontSize',14,'FontName',"Times")
xlabel("GNSS "+ Label)
ylabel("InSAR "+ Label)
axis equal
xlim(LIM)
ylim(LIM)
TEXT= sprintf("R^2= %0.2f\n Slope: %0.2f \\pm %0.2f(1\\sigma)\n Intercept: %0.2f \\pm %0.2f(1\\sigma)\n \\itp\\rm-value (1:1): %0.2f",...
    Statistics.Rsquared,Statistics.Slope,Statistics.SlopeUncertainty,Statistics.Intercept, ...
    Statistics.InterceptUncertainty,pvalue);
% text(.95,.05,TEXT,...
%     "Units","normalized",'FontName',"Times",'FontSize',16, ...
%     'HorizontalAlignment','right','VerticalAlignment','bottom')
legend("1:1 Line","2\sigma Error","","Data","2\sigma Uncertainty","Best Fit", ...
    "Location","northwest")

filename= "Figures/scatter_velocity.pdf";
savePDF(filename)


%% Co-seismic

fignum= 2;
k= 3;
Label= "LOS Co-seismic Displacement (mm)";
LIM= [-400 200];
IDexclude= [IDempty; ""];

[IDkeep,Ikeep]= setdiff(ID,IDexclude);
IDlabel= ["TOWG" "CCCC" "COSO" "P597" "P594" "P580"];

Xquery= linspace(LIM(1),LIM(2),100);
x= GNSSParamMean(k,Ikeep)';
y= InSARParamMean(k,Ikeep)';
ux= GNSSParamStd(k,Ikeep)';
uy= InSARSigmaUncertainty(k);
[Mean,Uncertainty,~,Statistics]= ...
    simpleLinearRegressionMonteCarlo(x,y,.01,InSARSigmaUncertainty(k),Xquery);
[~,Ilabel]= intersect(IDkeep,IDlabel);
[~,pvalue]= kstest((y-x)./hypot(ux,uy));


figure(fignum)
clf
set(gcf,"Position",FIGPOS)
set(gca,"Position",AXISPOS)
plot(LIM,LIM,'k--')
hold on
plotUncertainty(Xquery,Mean,Uncertainty,[.8 0 0])
hold on
errorbar3(x,y,2*ux,2*uy,1,[0 0 0 ],.4,30,1)
hold off
setOptions
text(x(Ilabel)+5,y(Ilabel),IDkeep(Ilabel),'FontSize',14,'FontName',"Times")
xlabel("GNSS "+ Label)
ylabel("InSAR "+ Label)
axis equal
xlim(LIM)
ylim(LIM)
TEXT= sprintf("R^2= %0.2f\n Slope: %0.2f \\pm %0.2f(1\\sigma)\n Intercept: %0.2f \\pm %0.2f(1\\sigma)\n \\itp\\rm-value (1:1): %0.2f",...
    Statistics.Rsquared,Statistics.Slope,Statistics.SlopeUncertainty,Statistics.Intercept, ...
    Statistics.InterceptUncertainty,pvalue);
% text(.95,.05,TEXT,...
%     "Units","normalized",'FontName',"Times",'FontSize',16, ...
%     'HorizontalAlignment','right','VerticalAlignment','bottom')
% legend("1:1 Line","2\sigma Uncertainty","Best Fit","2\sigma Error","","Data", ...
%     "Location","northwest")


filename= "Figures/scatter_coseismic.pdf";
savePDF(filename)

LIM= [-1 1]*25;
fignum= 10;
figure(fignum)
clf
set(gcf,"Position",FIGPOS./[1 1 3 3])
set(gca,"Position",AXISPOS)
plot(LIM,LIM,'k--')
hold on
plotUncertainty(Xquery,Mean,Uncertainty,[.8 0 0])
hold on
errorbar3(x,y,2*ux,2*uy,1,[0 0 0 ],.4,30,1)
hold off
setOptions
% text(x(Ilabel)+5,y(Ilabel),IDkeep(Ilabel),'FontSize',14,'FontName',"Times")
% xlabel("GNSS "+ Label)
% ylabel("InSAR "+ Label)
axis equal
xlim(LIM)
ylim(LIM)
xticks(-20:20:20)
yticks(-20:20:20)
TEXT= sprintf("R^2= %0.2f\n Slope: %0.2f \\pm %0.2f(1\\sigma)\n Intercept: %0.2f \\pm %0.2f(1\\sigma)\n \\itp\\rm-value (1:1): %0.2f",...
    Statistics.Rsquared,Statistics.Slope,Statistics.SlopeUncertainty,Statistics.Intercept, ...
    Statistics.InterceptUncertainty,pvalue);
% text(.95,.05,TEXT,...
%     "Units","normalized",'FontName',"Times",'FontSize',16, ...
%     'HorizontalAlignment','right','VerticalAlignment','bottom')
% legend("1:1 Line","2\sigma Uncertainty","Best Fit","2\sigma Error","","Data", ...
%     "Location","northwest")

filename= "Figures/scatter_coseismicSmall.pdf";
savePDF(filename)



%% Post-Seismic

fignum= 3;
k= 4;
Label= "LOS Post-seismic (mm)";
LIM= [-1 1]*35;
IDexclude= [IDempty' "TOWG"];

[IDkeep,Ikeep]= setdiff(ID,IDexclude);
IDlabel= ["P568" "CCCC" "COSO" "P594" "P580" "P463" "P595"];
% IDlabel= IDkeep;

Xquery= linspace(LIM(1),LIM(2),100);
x= GNSSParamMean(k,Ikeep)';
y= InSARParamMean(k,Ikeep)';
ux= GNSSParamStd(k,Ikeep)';
uy= InSARSigmaUncertainty(k);
[Mean,Uncertainty,~,Statistics]= ...
    simpleLinearRegressionMonteCarlo(x,y,ux,uy,Xquery);
[~,Ilabel]= intersect(IDkeep,IDlabel);
[~,pvalue]= kstest((y-x)./hypot(ux,uy));

figure(fignum)
clf
set(gcf,"Position",FIGPOS)
set(gca,"Position",AXISPOS)
plot(LIM,LIM,'k--')
hold on
errorbar3(x,y,2*ux,2*uy,1,[0 0 0 ],.4,30,1)
plotUncertainty(Xquery,Mean,Uncertainty,[.8 0 0])
hold off
setOptions
text(x(Ilabel)+1,y(Ilabel),IDkeep(Ilabel),'FontSize',14,'FontName',"Times")
xlabel("GNSS "+ Label)
ylabel("InSAR "+ Label)
axis equal
xlim(LIM)
ylim(LIM)
TEXT= sprintf("R^2= %0.2f\n Slope: %0.2f \\pm %0.2f(1\\sigma)\n Intercept: %0.2f \\pm %0.2f(1\\sigma)\n \\itp\\rm-value (1:1): %0.2f",...
    Statistics.Rsquared,Statistics.Slope,Statistics.SlopeUncertainty,Statistics.Intercept, ...
    Statistics.InterceptUncertainty,pvalue);
% text(.95,.05,TEXT,...
%     "Units","normalized",'FontName',"Times",'FontSize',16, ...
%     'HorizontalAlignment','right','VerticalAlignment','bottom')
% legend("1:1 Line","2\sigma Error","","Data","2\sigma Uncertainty","Best Fit", ...
%     "Location","northwest")

filename= "Figures/scatter_postseismic.pdf";
% savePDF(filename)






% %% Post-Seismic 60KM

% PSfactor= 1-exp(-1/1.8);
% 
% fignum= 4;
% k= 4;
% Label= "LOS Post-seismic @ 1yr (mm)";
% LIM= [-1 1]*15;
% IDexclude= [IDempty' "TOWG"];

IDkeep2= sort(["CCCC" "COSO" "P594" "P580" "P616" "RAMT" "P593" "P463" "P464"]);
% [IDkeep,Ikeep]= setdiff(ID,IDexclude);
[~,Ikeep2]= intersect(ID,IDkeep2);

IDlabel= sort(["CCCC" "COSO" "P594" "P580" "P616" "P593" "P464"]);

Xquery= linspace(LIM(1),LIM(2),100);
x= GNSSParamMean(k,Ikeep2)';
y= InSARParamMean(k,Ikeep2)';
ux= GNSSParamStd(k,Ikeep2)';
uy= InSARSigmaUncertainty(k);
[Mean2,Uncertainty2,~,Statistics2]= ...
    simpleLinearRegressionMonteCarlo(x,y,ux,uy,Xquery);
[~,Ilabel]= intersect(IDkeep,IDlabel);
[~,pvalue]= kstest((y-x)./hypot(ux,uy));

% figure(fignum)
% set(gcf,"Position",FIGPOS./[1 1 2.5 2.5])
% set(gca,"Position",AXISPOS)
% plot(LIM,LIM,'k--')
hold on
scatter(x,y,80,'k')
h= plotUncertainty(Xquery,Mean2,Uncertainty2,[0 0 .8],.05);
h.LineStyle= "--";
hold off

legend("","","","","","","Data <60km","2\sigma Uncertainty", ...
    "Best Fit (<60km)",'Location','northwest')
annotation("ellipse",[.2083, .9005, .005, .006],'FaceColor','k')

savePDF(filename)

% setOptions
% text(x(Ilabel)+.5,y(Ilabel),IDkeep(Ilabel),'FontSize',14,'FontName',"Times")
% xlabel("GNSS "+ Label)
% ylabel("InSAR "+ Label)
% axis equal
% xlim(LIM)
% ylim(LIM)
% xticks(-15:15:15)
% yticks(-15:15:15)
TEXT= sprintf("R^2= %0.2f\n Slope: %0.2f \\pm %0.2f(1\\sigma)\n Intercept: %0.2f \\pm %0.2f(1\\sigma)\n \\itp\\rm-value (1:1): %0.2f",...
    Statistics2.Rsquared,Statistics2.Slope,Statistics2.SlopeUncertainty,Statistics2.Intercept, ...
    Statistics2.InterceptUncertainty,pvalue);
% text(.95,.05,TEXT,...
%     "Units","normalized",'FontName',"Times",'FontSize',16, ...
%     'HorizontalAlignment','right','VerticalAlignment','bottom')
% legend("1:1 Line","2\sigma Error","","Data","2\sigma Uncertainty","Best Fit", ...
%     "Location","northwest")

% filename= "Figures/scatter_postseismic60km.pdf";
% savePDF(filename)
