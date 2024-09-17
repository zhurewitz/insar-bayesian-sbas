%% Plot Interferogram

function [h,c,illuminationImage]= plotInterferogram( ...
    h5filename,Flag,Mission,Track,PrimaryDate, SecondaryDate, drawSquare, ...
    drawElevation, ReferenceLongitude, ReferenceLatitude,Range)

arguments
    h5filename
    Flag {mustBeMember(Flag,["L1","L2","L3"])}
    Mission
    Track
    PrimaryDate
    SecondaryDate
    drawSquare= false;
    drawElevation= true;
    ReferenceLongitude= [];
    ReferenceLatitude= [];
    Range= [];
end

commonGrid= h5.readGrid(h5filename,'/grid');

% Background color
oceanColor= single([.6 .6 .6]);
C= zeros(commonGrid.Size,'single')+ reshape(oceanColor,1,1,3);


%% Elevation

if drawElevation
    Elevation= h5.read(h5filename,'/grid','elevation');

    illumination= plt.topographyShading(Elevation);
    
    illuminationImage= plt.utils.addLayer(C,.4+.5*illumination);
end


%% Interferogram

Stack= io.loadStack(h5filename,Flag,Mission,Track,PrimaryDate,SecondaryDate);

if isempty(Range)
    Range= 100*[-1 1];
end
if drawElevation
    backgroundColor= nan;
else
    backgroundColor= .8;
end
interferogramImage= plt.toColorSimple(Stack,single(plt.colormap2('redblue')),Range,backgroundColor);

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
% set(gca,'GridColor',[0 0 0],'GridAlpha',1,'GridLineWidth',1)

text(.02,.02,sprintf('Mission: %s \nTrack: %d \n%s - %s',...
    Mission,Track,string(PrimaryDate,'MMM d, yyyy'), ...
    string(SecondaryDate,'MMM dd, yyyy')),'Units','normalized','FontSize',16, ...
    'FontName','Times','VerticalAlignment','bottom')

if drawSquare
    xmean= mean(commonGrid.Long);
    ymean= mean(commonGrid.Lat);

    dx= min(std(commonGrid.Long),std(commonGrid.Lat));
    xbounds= xmean+ [-1 1]*dx/cosd(ymean);
    ybounds= ymean+ [-1 1]*dx;

    hold on
    plot(xbounds([1 2 2 1 1 2 2 1]),ybounds([1 1 2 2 1 2 1 2]),'LineWidth',2)
    hold off
end

if ~isempty(ReferenceLatitude)
    hold on
    plot(polyshape(ReferenceLongitude,ReferenceLatitude),'FaceColor','none','LineWidth',1)
    hold off
end

end



