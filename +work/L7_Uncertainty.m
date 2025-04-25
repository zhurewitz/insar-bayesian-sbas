

load input.mat workdir

filename= fullfile(workdir,"L5output.mat");
load(filename,"Date",'PosteriorCovariance')

filename2= fullfile(workdir,"L3_SBASCovariance.mat");
load(filename2,"PostingDate","SBASCovariance")

filename3= fullfile(workdir,"L5_StochasticCovariance.mat");
load(filename3,"Date","StochasticCovariance")

% Parameter Matrix
ReferenceDate= datetime(2015,1,1);
A= utils.parameterMatrix2(Date,1,1,1,0,0,ReferenceDate,1.8);

% Parameter Prior Covariance
ParameterCovariance= 20000*eye(4);

% Prior Covariance
Bx= A*ParameterCovariance*A'+ StochasticCovariance;



%%

Ndate= length(Date);

Uncertainty= sqrt(diag(PosteriorCovariance));

rng(0)
Nsamples= 5;
Neig= 180;
Samples= matrixsqrt(PosteriorCovariance,Neig)*randn(Neig,Nsamples);


figure(1)
set(gcf,'Position',[36         516        1119         281])
clf
tiledlayoutcompact("",1,3)
imagesc(PosteriorCovariance)
c= colorbar;
setOptions
colormap2('redblue','Range',[-2 6])
axis equal
xlim([0 Ndate])
ylim([0 Ndate])
DateTicks= datetime(2015:5:2025,1,1);
xticks(linspace(0,Ndate,3))
xticklabels(string(DateTicks,"yyyy"))
yticks(linspace(0,Ndate,3))
yticklabels(string(DateTicks,"yyyy"))
c.Label.String= "Covariance (mm^2)";
c.Location= "east";
c.Label.FontSize= 16;
text(3/100,93/100, 'a','FontSize',25,'FontName','Times','FontWeight','bold','Units','normalized')


% nexttile
% plot(Date,Uncertainty,'LineWidth',2)
% setOptions
% xlim(datetime([2015 2025],1,1))
% xticks(datetime(2015:5:2025,1,1))
% ylabel("1\sigma Uncertainty (mm)")

nexttile(2,[1,2])
hold on
areaBetween(Date,-3*Uncertainty,3*Uncertainty,[0 0 0]+ .8)
areaBetween(Date,-2*Uncertainty,2*Uncertainty,[0 0 0]+.6)
areaBetween(Date,-Uncertainty,Uncertainty,[0 0 0]+ .4)
plot(Date,Samples,'k','LineWidth',1)
setOptions
xlim(datetime([2015 2025],1,1))
xticks(datetime(2015:1:2025,1,1))
box on
ylabel("Uncertainty (mm)")
ylim([-1 1]*8)
text(2/100,92/100, 'b','FontSize',25,'FontName','Times','FontWeight','bold','Units','normalized')

exportgraphics(gcf,'Figures/uncertainty.pdf','ContentType','vector','BackgroundColor','none')



%%
Ndate= length(Date);
Nposting= length(PostingDate);

Uncertainty= sqrt(diag(PosteriorCovariance));
UncertaintySBAS= sqrt(diag(SBASCovariance));


rng(0)
Nsamples= 1;
Neig= 180;
Sample2= matrixsqrt(SBASCovariance,320)*randn(320,Nsamples);
Sample1= matrixsqrt(PosteriorCovariance,Neig)*randn(Neig,Nsamples);


figure(2)
clf
tiledlayoutcompact
hold on
areaBetween(Date,-2*Uncertainty,2*Uncertainty,[0 0 0]+ .8)
areaBetween(PostingDate,-2*UncertaintySBAS,2*UncertaintySBAS,[0 0 0]+ .6)
plot(Date,Sample1,'k','LineWidth',2)
plot(PostingDate,Sample2,'k','LineWidth',1)

setOptions
xlim(datetime([2015 2025],1,1))
xticks(datetime(2015:1:2025,1,1))
box on
ylabel("Uncertainty (mm)")
ylim([-1 1]*6)




%%


rng(0)
Nsamples= 10000;
Neig= 180;
Samples= matrixsqrt(PosteriorCovariance,Neig)*randn(Neig,Nsamples);

A= utils.parameterMatrix2(Date,1,1,1,0,0,ReferenceDate,1.8);

[params,~,~,RMSE]= utils.fitParams(Samples,A);

% AMP= hypot(params(5,:),params(6,:));

rms(RMSE)

COV= cov(params([1 3 4],:)');

ParamUncertainty= sqrt(diag(COV));

(COV./ParamUncertainty)./ParamUncertainty'

% 
% %%
% 
% figure(3)
% imagesc(COV)
% setOptions
% colorbar
% colormap2('redblue','Range',[-2 100])

% figure(3)
% histogram(AMP)
% setOptions

