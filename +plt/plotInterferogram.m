%% Plot Interferogram

function [h,illuminationImage]= plotInterferogram( ...
    h5filename,Flag,Mission,Track,PrimaryDate, SecondaryDate, drawSquare, ...
    drawElevation, drawClosureMask, ReferenceLongitude, ReferenceLatitude)

arguments
    h5filename
    Flag {mustBeMember(Flag,["L1","L2"])}
    Mission
    Track
    PrimaryDate
    SecondaryDate
    drawSquare= false;
    drawElevation= true;
    drawClosureMask= true;
    ReferenceLongitude= [];
    ReferenceLatitude= [];
end

commonGrid= h5.readGrid(h5filename,'/grid');

% Background color
oceanColor= single([.6 .6 .6]);
C= zeros(commonGrid.Size,'single')+ reshape(oceanColor,1,1,3);


%% Elevation

if drawElevation
    Elevation= h5.read(h5filename,'/grid','elevation');

    [GX,GY]= gradient(Elevation);

    GX= GX/111000*1200;
    GY= GY/111000*1200;

    Normal= cat(3,-GX,-GY,ones(size(Elevation)));
    Normal= Normal./sqrt(sum(Normal.^2,3));

    sunVector= [-1 1 1];
    sunVector= sunVector/norm(sunVector);

    illumination= sum(Normal.*reshape(sunVector,1,1,3),3);
    illumination(illumination < 0)= 0;
    
    illuminationImage= addLayer(C,.4+.5*illumination);
end


%% Interferogram

Stack= io.loadStack(h5filename,Flag,Mission,Track,PrimaryDate,SecondaryDate);

if drawClosureMask
    closureMask= io.loadClosureMask(h5filename,Mission,Track,PrimaryDate,SecondaryDate);
    
    Stack(closureMask)= nan;
end

RANGE= 100*[-1 1];
if drawElevation
    backgroundColor= nan;
else
    backgroundColor= .8;
end
interferogramImage= plt.toColorSimple(Stack,single(colormap2('redblue')),RANGE,backgroundColor);

C= addLayer(illuminationImage,interferogramImage,.8);



%% Plot

h= image(commonGrid.Long,commonGrid.Lat,C);
plt.pltOptions
c= colorbar;
c.Label.String= 'LOS Displacement (mm)';
plt.colormap2('redblue','Axis',gca,'Range',RANGE)
xlim(commonGrid.LongLim)
ylim(commonGrid.LatLim)

xticks(floor(commonGrid.LongLim(1)):ceil(commonGrid.LongLim(2)))
yticks(floor(commonGrid.LatLim(1)):ceil(commonGrid.LatLim(2)))

XTICKS= xticks;
XTICKLABELS= "";
for i= 1:length(XTICKS)
    if sign(XTICKS(i)) < 0; dir= 'W'; else; dir= 'E'; end
    XTICKLABELS(i)= strcat(string(abs(XTICKS(i))),char(176),dir);
end
YTICKS= yticks;
YTICKLABELS= "";
for i= 1:length(YTICKS)
    if sign(YTICKS(i)) < 0; dir= 'S'; else; dir= 'N'; end
    YTICKLABELS(i)= strcat(string(abs(YTICKS(i))),char(176),dir);
end
xticklabels(XTICKLABELS)
yticklabels(YTICKLABELS)
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




%% Add Transparent Layer 

function C= addLayer(C1,C2,Alpha)

arguments
    C1
    C2
    Alpha= [];
end

if all(size(C1,[1 2]) == [1 1])
    C1= repmat(C1,size(C2,1),size(C2,2));
end

if size(C1,3) == 1 & size(C2,3) == 3
    C1= repmat(C1,1,1,3);
elseif size(C1,3) == 3 & size(C2,3) == 1
    C2= repmat(C2,1,1,3);
end

Inan1= isnan(C1);
Inan2= isnan(C2);

C= nan(size(C1));

I= Inan1 & ~Inan2;
C(I)= C2(I);

I= ~Inan1 & Inan2;
C(I)= C1(I);

I= ~Inan1 & ~Inan2;
if ~isempty(Alpha)
C(I)= C1(I)*(1-Alpha)+ C2(I)*Alpha;
else
    C(I)= C2(I);
end

end


