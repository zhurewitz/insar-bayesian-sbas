%% Plot Displacement

function [h,c]= plotImage3(Z,illuminationImage,GridLong,GridLat,cmap,z)

arguments
    Z
    illuminationImage
    GridLong
    GridLat
    cmap= [];
    z= [-100 100];
end

if isempty(cmap)
    cmap= plt.colormap2('redblue','Data',z);
end

IM= plt.toColor2(Z,single(cmap),z,nan);

C= plt.utils.addLayer(illuminationImage,IM,.8);

h= image(GridLong,GridLat,C);
plt.pltOptions
c= colorbar;
plt.colormap2(cmap,'Axis',gca,'Range',z)
xlim(GridLong([1 end]))
ylim(GridLat([1 end]))
daspect([cosd(mean(GridLat)) 1 1])

plt.utils.latLongTicks

grid on

end