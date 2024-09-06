%% Plot Displacement

function [h,c,illuminationImage]= plotDisplacement( ...
    L3filename,Mission,Track,k,Range)

arguments
    L3filename
    Mission= [];
    Track= [];
    k= 1;
    Range= [-100 100];
end

[Missions,Tracks]= io.readMissionTracks(L3filename,"L3");

if isempty(Mission)
    Mission= Missions(1);
end

if isempty(Track)
    Track= Tracks(1);
end

commonGrid= h5.readGrid(L3filename,'/grid');



%% Elevation

% Background color
oceanColor= single([.6 .6 .6]);
C= zeros(commonGrid.Size,'single')+ reshape(oceanColor,1,1,3);

Elevation= h5.read(L3filename,'/grid','elevation');

illumination= plt.topographyShading(Elevation);

illuminationImage= addLayer(C,.4+.5*illumination);



%% Image

Page= io.loadPage(L3filename,"L3",Mission,Track,k);

interferogramImage= plt.toColorSimple(Page,single(plt.colormap2('redblue')),Range,nan);

C= plt.utils.addLayer(illuminationImage,interferogramImage,.8);



%% Plot

h= image(commonGrid.Long,commonGrid.Lat,C);
plt.pltOptions
c= colorbar;
c.Label.String= 'LOS Displacement (mm)';
plt.colormap2('redblue','Axis',gca,'Range',Range)
xlim(commonGrid.LongLim)
ylim(commonGrid.LatLim)

plt.utils.latLongTicks

grid on

text(.02,.02,sprintf('Mission: %s \nTrack: %d \n%s - %s',...
    Mission,Track,string(Date,'MMM d, yyyy')), ...
    'Units','normalized','FontSize',16, ...
    'FontName','Times','VerticalAlignment','bottom')

end






