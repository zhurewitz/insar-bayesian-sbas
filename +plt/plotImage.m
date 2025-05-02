%% Plot Displacement

function [h,c]= plotImage(GridLong,GridLat,Z,illuminationImage,cmap,Range)

arguments
    GridLong
    GridLat
    Z
    illuminationImage
    cmap= [];
    Range= [-100 100];
end

if isempty(cmap)
    cmap= plt.colormap2('redblue','Range',Range);
end

IM= plt.toColorSimple(Z,single(cmap),Range,nan);

C= plt.utils.addLayer(illuminationImage,IM,.8);

hhandle= image(GridLong,GridLat,C);
plt.pltOptions
chandle= colorbar;
plt.colormap2(cmap,'Axis',gca,'Range',Range)
xlim(GridLong([1 end]))
ylim(GridLat([1 end]))

plt.utils.latLongTicks

grid on


if nargout > 0
    h= hhandle;
end

if nargout > 1
    c= chandle;
end


end