

load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);
Size= [length(GridLat) length(GridLong)];
Nposting= length(PostingDate);

% 147
K= [95 88 208 268 165 216];
Nk= length(K);

TroposphereQuery= nan([Size Nk]);

for i= 1:Nk
    TroposphereQuery(:,:,i)= d3.readPage(TroposphereFile,K(i));
end

%%

IM= imtile(TroposphereQuery(1:4:end,1:4:end,:),[],"GridSize",[2, 3]);




figure(1)
clf
setFigureSize(1200,700)
imagesc(IM)
c= colorbar;
c.Label.String= "LOS Tropospheric Delay (mm)";
setOptions
axis off
clim([-1 1]*50)
colormap gray
daspect([1 cosd(35) 1])

text(.01,.97,'a','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')
text(.345,.97,'b','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')
text(.677,.97,'c','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')
text(.01,.47,'d','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')
text(.345,.47,'e','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')
text(.677,.47,'f','FontSize',30,'FontName','Times','FontWeight','bold', ...
    'Color','w','Units','normalized')

text(.01,.97-.44,string(PostingDate(K(4)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','w','Units','normalized')
text(.345,.97-.44,string(PostingDate(K(5)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','w','Units','normalized')
text(.677,.97-.44,string(PostingDate(K(6)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','w','Units','normalized')
text(.01,.47-.44,string(PostingDate(K(1)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','w','Units','normalized')
text(.345,.47-.44,string(PostingDate(K(2)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','w','Units','normalized')
text(.677,.47-.44,string(PostingDate(K(3)),'MMM d, yyyy'), ...
    'FontSize',14,'FontName','Times', ...
    'Color','k','Units','normalized')

savePDF("Figures/troposphere.pdf")


%%

figure(2)
clf
% setFigureSize(1200,700)
imagesc(TroposphereQuery(950:1200,520:850,1))
setOptions
axis off
clim([-1 1]*50)
colormap gray
daspect([1 cosd(35) 1])

savePDF("Figures/tropospherePostSeismic.pdf")