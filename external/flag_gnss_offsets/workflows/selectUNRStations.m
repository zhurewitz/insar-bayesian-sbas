%% Select UNR Stations
% Select and Save List of GNSS Stations from UNR
% Station details at: http://geodesy.unr.edu/PlugNPlayPortal.php

% Bounding box
LatLim= [34.75 37.75];
LongLim= [-122 -118];

% Output filename
filename= 'CVstations.txt';

% Plot
figure(1)
displayBoundingBox(LatLim,LongLim);

% Save file
saveStations(filename,LatLim,LongLim)




%% Plot

function displayBoundingBox(LatLim,LongLim)

displayFactor= 2;

XLIM= mean(LongLim)+ displayFactor*.5*[-1 1]*diff(LongLim);
YLIM= mean(LatLim)+ displayFactor*.5*[-1 1]*diff(LatLim);

Stations= flag.downloadUNRStations;

clf
set(gcf,'Color','white')
geoaxes('Basemap','topographic');

geoplot(LatLim([1 2 2 1 1]),LongLim([1 1 2 2 1]),'LineWidth',2);
hold on
geoscatter(Stations.Latitude,Stations.Longitude,30,'k^','filled');
hold off
geolimits(YLIM,XLIM)
set(gca,'FontSize',16,'FontName','Times')

end



%% Save Stations in Text File

function saveStations(filename,LatLim,LongLim)

if isempty(filename)
    fprintf('No output file selected, not saving\n')
    return
end

Stations= flag.downloadUNRStations;

I= (LatLim(1) <= Stations.Latitude & Stations.Latitude <= LatLim(2)) &...
   (LongLim(1) <= Stations.Longitude & Stations.Longitude <= LongLim(2));

writelines(Stations.ID(I),filename)

fprintf('SelectUNRStations: %d stations saved to %s\n',sum(I),filename)

end