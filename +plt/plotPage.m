%% Plot Displacement

function [h,c]= plotPage(Page,illuminationImage,commonGrid,Range)

arguments
    Page
    illuminationImage
    commonGrid
    Range= [-100 100];
end

IM= plt.toColorSimple(Page,single(plt.colormap2('redblue','Range',Range)),Range,nan);

C= plt.utils.addLayer(illuminationImage,IM,.8);

h= image(commonGrid.Long,commonGrid.Lat,C);
plt.pltOptions
c= colorbar;
c.Label.String= 'LOS Displacement (mm)';
plt.colormap2('redblue','Axis',gca,'Range',Range)
xlim(commonGrid.LongLim)
ylim(commonGrid.LatLim)

plt.utils.latLongTicks

grid on

end






