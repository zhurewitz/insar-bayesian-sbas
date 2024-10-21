%% Detrend Interferogram by Elevation and Reference Area
% Stratified atmosphere can cause elevation-correlated signals
% in the interferograms, which we estimate with a linear trend.
% Additionally, we estimate the long-wavelength spatial trend
% (to user-defined polynomial order in x and y) within the
% reference area. Only evaluate using high-coherence pixels.

function [LOS,elevationTrend,trendMeta]= detrendInterferogramByElevationAndReferenceArea(...
    LOS,COH,Elevation,metaGrid,inReference,referenceTrendMatrix,commonTrendMatrix,metaTrendMatrix)

Size= size(LOS);

CORRECTION= zeros(Size);
CORRECTIONprevious= zeros(Size);
trendMeta= zeros(metaGrid.Size);
elevationTrend= 0;

Ielev= ~isnan(LOS) & ~isnan(Elevation) & COH >= 0.7;
E= Elevation/max(Elevation,[],'all'); % Normalized elevation

for it= 1:20
    % Trend with Elevation
    p1= polyfit(E(Ielev),LOS(Ielev)- CORRECTION(Ielev),1);
    CORRECTION= CORRECTION+ polyval([p1(1) 0],E);

    % Document the elevation trend
    elevationTrend= elevationTrend+ p1(1)/max(Elevation,[],'all');


    % Detrend Interferogram to Reference Area
    v= LOS(inReference)- CORRECTION(inReference);
    Idata= ~isnan(v) & COH(inReference) >= 0.7;
    p2= referenceTrendMatrix(Idata,:)\v(Idata);
    CORRECTION= CORRECTION+ reshape(commonTrendMatrix*p2,Size);

    % Document the trend on the metaGrid
    trendMeta= trendMeta+ reshape(metaTrendMatrix*p2,metaGrid.Size);

    if rms(CORRECTION- CORRECTIONprevious,'all','omitnan') < .01
        break
    end
    CORRECTIONprevious= CORRECTION;
end

% Perform the correction
LOS= LOS- CORRECTION;

end


