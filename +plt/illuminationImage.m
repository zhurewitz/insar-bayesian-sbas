%% Background Illumination

function IM= illuminationImage(Elevation)

Size= size(Elevation);

% Background color
oceanColor= single([.6 .6 .6]);
C= zeros(Size,'single')+ reshape(oceanColor,1,1,3);

illumination= plt.topographyShading(Elevation);

IM= plt.utils.addLayer(C,.4+.5*illumination);


end
