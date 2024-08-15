%% Select UNR Stations
% Select and Save List of GNSS Stations from UNR
% Station details at: http://geodesy.unr.edu/PlugNPlayPortal.php

function selectUNRStations(workdir,LatLim,LongLim)

% Plot
displayBoundingBox(workdir,LatLim,LongLim);

% Save file
saveStations(workdir,LatLim,LongLim)

end



%% Plot

function displayBoundingBox(workdir,LatLim,LongLim)

displayFactor= 2;

XLIM= mean(LongLim)+ displayFactor*.5*[-1 1]*diff(LongLim);
YLIM= mean(LatLim)+ displayFactor*.5*[-1 1]*diff(LatLim);

Stations= gnss.downloadUNRStations;

clf
set(gcf,'Color','white')
geoaxes('Basemap','topographic');

geoplot(LatLim([1 2 2 1 1]),LongLim([1 1 2 2 1]),'LineWidth',2);
hold on
geoscatter(Stations.Latitude,Stations.Longitude,30,'k^','filled');
hold off
geolimits(YLIM,XLIM)
set(gca,'FontSize',16,'FontName','Times')

PNGfilename= fullfile(workdir,"GNSS/allGNSSstations.png");
exportgraphics(gcf,PNGfilename,"Resolution",300)

PDFfilename= fullfile(workdir,"GNSS/allGNSSstations.pdf");
exportgraphics(gcf,PDFfilename)

end



%% Save Stations in Text File

function saveStations(workdir,LatLim,LongLim)

filename= fullfile(workdir,'GNSS/allGNSSstations.txt');

Stations= flag.downloadUNRStations;

I= (LatLim(1) <= Stations.Latitude & Stations.Latitude <= LatLim(2)) &...
   (LongLim(1) <= Stations.Longitude & Stations.Longitude <= LongLim(2));

writelines(Stations.ID(I),filename)

fprintf('SelectUNRStations: %d stations saved to %s\n',sum(I),filename)

end