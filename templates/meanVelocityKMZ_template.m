%% Mean Velocity to KMZ

workdir= "/Volumes/Zel's Work Drive/Work/CV-ARIA5-BOTH2/";
GoogleEarthDir= '/Users/zhurewit/Workspace/Google Earth/BInSAR Development';



Flag= "L1";
Mission= "S1";
Track= 137;

% Colormap limits
CLIM= [-40 40];




%% Read Stacks and Save

switch Flag
    case "L1"
        h5filename= fullfile(workdir,'processingStoreL1.h5');
    case "L2"
        h5filename= fullfile(workdir,'processingStoreL2.h5');
    case "L3"
        h5filename= fullfile(workdir,'processingStoreL3.h5');
end

grid= h5.readGrid(h5filename,'/grid');

Nx= diff(grid.LongLim)/.25;
Ny= diff(grid.LatLim)/.25;

meanVelocity= nan(grid.Size,'single');
standardDeviation= nan(grid.Size,'single');


figure(1)
h= imagesc(grid.Long,grid.Lat,meanVelocity);
plt.pltOptions
plt.colormap2('redblue','Range',CLIM)
c= colorbar;
c.Label.String= 'LOS Upwards Velocity (cm/yr)';

for j= 1:Ny
    for i= 1:Nx
        LatLim= grid.LatLim(1)+ .25*(j-1)+ [0 .25];
        LongLim= grid.LongLim(1)+ .25*(i-1)+ [0 .25];
        
        [Velocity,~,PrimaryDate,SecondaryDate]=...
            io.loadStack(h5filename,Flag,Mission,Track,[],[],LatLim,LongLim);
        
        dt= reshape(years(SecondaryDate-PrimaryDate),1,1,[]);
        
        Velocity= .1*Velocity./dt; % Convert mm displacement to cm/yr velocity
        
        meanVelocityTile= mean(Velocity,3,'omitmissing');
        standardDeviationTile= std(Velocity,[],3,'omitmissing');
        
        I= (1:300)+ 300*(i-1);
        I= I(I <= grid.Size(2));
        
        J= (1:300)+ 300*(j-1);
        J= J(J <= grid.Size(1));
        
        meanVelocity(J,I)= meanVelocityTile;
        standardDeviation(J,I)= standardDeviationTile;
        
        h.CData= meanVelocity;
        drawnow
    end
end


%% Write Mean Velocity as KMZ

backgroundColor= 0;
cmap= plt.colormap2('redblue');
Image= plt.toColorSimple(meanVelocity,single(cmap),CLIM,backgroundColor);

Mask= .8*(~isnan(meanVelocity))+ .2;


infname= strcat('MeanVelocity-',Mission,'-',string(Track));

utils.writeKMZImage(GoogleEarthDir,infname,grid.LatLim,grid.LongLim,...
    Image,Mask);



%% Write Standard Deviation as KMZ

backgroundColor= 0;
cmap= plt.colormap2('sunset');
Image= plt.toColorSimple(standardDeviation,single(cmap),[0 200],...
    backgroundColor);

Mask= .8*(~isnan(standardDeviation))+ .2;


infname= strcat('StandardDeviation-',Mission,'-',string(Track));

utils.writeKMZImage(GoogleEarthDir,infname,grid.LatLim,grid.LongLim,...
    Image,Mask);

