load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);

if ~exist("Troposphere",'var')
    Troposphere= d3.read(TroposphereFile);
end


%%

Iwinter= any(month(PostingDate) == [12 1 2],2);
Isummer= any(month(PostingDate) == [6 7 8],2);

MEANWINTER= mean(Troposphere(1:4:end,1:4:end,Iwinter),3,"omitmissing");
MEANSUMMER= mean(Troposphere(1:4:end,1:4:end,Isummer),3,"omitmissing");

STDWINTER= std(Troposphere(1:4:end,1:4:end,Iwinter),[],3,"omitmissing");
STDSUMMER= std(Troposphere(1:4:end,1:4:end,Isummer),[],3,"omitmissing");



%%

N= 256;
nanColor= [0 0 0];

CLIM= [-1 1]*10;
X= [MEANWINTER MEANSUMMER];
cmap= gray(N);
z= linspace(CLIM(1),CLIM(2),N);
col= toColor2(X,cmap,z,nanColor);

figure(1)
clf
tiledlayoutcompact("",2,3,false)
nexttile([1 2])
imagesc(col)
c= colorbar;
setOptions
axis off
clim(CLIM)
colormap2(cmap,'Axis',gca)
daspect([1 cosd(35) 1])
c.Label.String= "Mean LOS Tropospheric Delay (mm)";

text(.25,-.05,'Winter','FontName','Times','FontSize',16,'FontWeight','bold', ...
    'HorizontalAlignment','center','Units','normalized')
text(.75,-.05,'Summer','FontName','Times','FontSize',16,'FontWeight','bold', ...
    'HorizontalAlignment','center','Units','normalized')

CLIM= [-1 1]*10;
X= -MEANWINTER +MEANSUMMER;
cmap= colormap2('squirt',N);
z= linspace(CLIM(1),CLIM(2),N);
col= toColor2(X,cmap,z,nanColor);

nexttile
imagesc(col)
c= colorbar;
setOptions
axis off
clim(CLIM)
colormap2(cmap,'Axis',gca)
daspect([1 cosd(35) 1])
c.Label.String= "Difference (mm)";

CLIM= [0 1]*30;
X= [STDWINTER STDSUMMER];
cmap= colormap2('sunset',N);
z= linspace(CLIM(1),CLIM(2),N);
col= toColor2(X,cmap,z,nanColor);

nexttile([1 2])
imagesc(col)
c= colorbar;
setOptions
axis off
clim(CLIM)
colormap2(cmap,'Axis',gca)
daspect([1 cosd(35) 1])
c.Label.String= "STD. LOS Tropospheric Delay (mm)";

text(.25,-.05,'Winter','FontName','Times','FontSize',16,'FontWeight','bold', ...
    'HorizontalAlignment','center','Units','normalized')
text(.75,-.05,'Summer','FontName','Times','FontSize',16,'FontWeight','bold', ...
    'HorizontalAlignment','center','Units','normalized')



CLIM= [-1 1]*20;
X= -STDWINTER+ STDSUMMER;
cmap= colormap2('redblue',N,'flip');
z= linspace(CLIM(1),CLIM(2),N);
col= toColor2(X,cmap,z,nanColor);

nexttile
imagesc(col)
c= colorbar;
setOptions
axis off
clim(CLIM)
colormap2(cmap,'Axis',gca)
daspect([1 cosd(35) 1])
c.Label.String= "Difference (mm)";


savePDF("Figures/summerWinter.pdf")