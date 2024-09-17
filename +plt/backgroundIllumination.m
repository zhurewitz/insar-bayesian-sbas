%% Background Illumination

function illuminationImage= backgroundIllumination(h5filename)

Elevation= h5.read(h5filename,'/grid','elevation');

Size= size(Elevation);

% Background color
oceanColor= single([.6 .6 .6]);
C= zeros(Size,'single')+ reshape(oceanColor,1,1,3);

illumination= plt.topographyShading(Elevation);

illuminationImage= plt.utils.addLayer(C,.4+.5*illumination);


end
