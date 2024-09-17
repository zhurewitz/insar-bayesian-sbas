%% Plot Displacement

function [h,c]= plotImage(Z,illuminationImage,commonGrid,cmap,Range)

arguments
    Z
    illuminationImage
    commonGrid
    cmap= [];
    Range= [-100 100];
end

if isempty(cmap)
    cmap= plt.colormap2('redblue','Range',Range);
end

IM= plt.toColorSimple(Z,single(cmap),Range,nan);

C= plt.utils.addLayer(illuminationImage,IM,.8);

h= image(commonGrid.Long,commonGrid.Lat,C);
plt.pltOptions
c= colorbar;
plt.colormap2(cmap,'Axis',gca,'Range',Range)
xlim(commonGrid.LongLim)
ylim(commonGrid.LatLim)

plt.utils.latLongTicks

grid on

end