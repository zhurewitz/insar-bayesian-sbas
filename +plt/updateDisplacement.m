%% Plot Displacement

function updateDisplacement( ...
    L3filename,Mission,Track,k,h,illuminationImage,Text,Range)

arguments
    L3filename
    Mission= [];
    Track= [];
    k= 1;
    h= [];
    illuminationImage= [];
    Text= [];
    Range= [];
end

[Missions,Tracks]= io.readMissionTracks(L3filename,"L3");

if isempty(Mission)
    Mission= Missions(1);
end

if isempty(Track)
    Track= Tracks(1);
end

[Page,~,Date]= io.loadPage(L3filename,"L3",Mission,Track,k);



%% Image

if isempty(Range)
    Range= clim;
end

interferogramImage= plt.toColorSimple(Page,single(plt.colormap2('redblue')),Range,nan);

C= plt.utils.addLayer(illuminationImage,interferogramImage,.8);



%% Plot

h.CData= C;

Text.String= sprintf('Mission: %s \nTrack: %d \n%s',...
    Mission,Track,string(Date,'MMM d, yyyy'));

drawnow

end






