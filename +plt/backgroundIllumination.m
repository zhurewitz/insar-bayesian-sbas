%% Background Illumination
% Now DEFUNCT, replaced by plt.illuminationImage

function IM= backgroundIllumination(h5filename)

Elevation= h5.read(h5filename,'/grid','elevation');

IM= plt.illuminationImage(Elevation);


end
