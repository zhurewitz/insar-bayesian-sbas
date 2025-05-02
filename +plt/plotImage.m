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
dL= diff(GridLong(1:2));
xlim(GridLong([1 end])+ [0 dL]')
ylim(GridLat([1 end])+ [0 dL]')
daspect([1 cosd(mean(GridLat)) 1])

plt.utils.latLongTicks

grid on


if nargout > 0
    h= hhandle;
end

if nargout > 1
    c= chandle;
end


end