%% Level 2 Processing - Referencing

function [InterferogramFile,OutputFile]= ...
    L2b_Reference(workdir,fignum)

arguments
    workdir 
    fignum= 0;
end

ChunkSize= [200 200 1];

InputFile= fullfile(workdir,"L1interferogram.h5");
InterferogramFile= fullfile(workdir,"L2referenced.h5");
OutputFile= fullfile(workdir,"L2output.mat");


%% Load

% Load grid
[GridLong,GridLat,DatePairs]= d3.readXYZ(InputFile);
Size= [length(GridLat) length(GridLong)];
Ninf= height(DatePairs);

% Load coherence mask
CoherenceMaskFile= fullfile(workdir,"L1CoherenceMask");
load(CoherenceMaskFile,"CoherenceMask")

% Load coherence series
CoherenceSeriesFile= fullfile(workdir,"L1coherenceStatisticsSeries.mat");
load(CoherenceSeriesFile,"Fraction5") % HARD CODE ALERT




%% Construct Reference Area

% Read reference station locations
load GNSS4LOSdemean.mat ID ReferenceID StationLatitude StationLongitude
Nreference= length(ReferenceID);

% Reference station locations
[~,ia]= intersect(ID,ReferenceID);

% Locations of reference stations
ReferenceLat= StationLatitude(ia);
ReferenceLong= StationLongitude(ia);

% Calculate reference area
ReferenceArea= false(Size);
[LONG,LAT]= meshgrid(GridLong,GridLat);
for i= 1:Nreference
    % Great circle distance from all pixels to station, converted from
    % degrees to km
    R= distance(ReferenceLat(i),ReferenceLong(i),LAT,LONG)*111;
    
    % Find all regions within 1 km of station
    I= R < 1;
    
    % Flag as part of the reference area
    ReferenceArea(I)= true;
end

clear I R LONG LAT 




%% Referencing

if fignum > 0
    figure(fignum)
    clf
    plt.tiledlayoutcompact
    h= imagesc(GridLong,GridLat,nan(Size));
    hold on
    scatter(StationLongitude,StationLatitude,100,'k','filled','Marker','diamond')
    scatter(ReferenceLong,ReferenceLat,30,'w','filled')
    hold off
    plt.pltOptions
    colorbar
    text(StationLongitude+.02,StationLatitude,ID,"FontSize",14,'FontName',"Times")

    nexttile
    h2= scatter(DatePairs(:,1),nan(Ninf,1),50,'k','filled');
    xlim([min(DatePairs(:)),max(DatePairs(:))])
    plt.pltOptions
    box on

end



tic
count= 1;
for k= 1:Ninf
    % REJECT INTERFEROGRAMS
    
    if any(isnat(DatePairs(k,:)),2)
        fprintf("No data for interferogram %d/%d. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    % ***HARD CODE ALERT***
    if Fraction5(k) < .7
        fprintf("Interferogram %d/%d does not meet coherence criteria. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    
    % Load Interferogram
    Interferogram= d3.readPage(InputFile,k);
    
    % No data
    if all(isnan(Interferogram),'all')
        fprintf("No data for interferogram %d/%d. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    
    % APPLY COHERENCE MASK
    Interferogram(~CoherenceMask)= nan;

    % Reference Interferogram
    ReferenceValue= mean(Interferogram(ReferenceArea),'omitmissing');
    Interferogram2= Interferogram- ReferenceValue;
    
    % Save Interferogram
    d3.writePage(InterferogramFile,Interferogram2,count,GridLong,GridLat,DatePairs(k,:),ChunkSize)
    
    RefTS= work.saveVariableMATFile(OutputFile,"ReferenceValue",ReferenceValue,count);
    PrimaryDate= work.saveVariableMATFile(OutputFile,"PrimaryDate",DatePairs(k,1),count);
    work.saveVariableMATFile(OutputFile,"SecondaryDate",DatePairs(k,2),count)
    
    
    h.CData= Interferogram2;
    h2.XData= PrimaryDate;
    h2.YData= RefTS;
    drawnow
    
    count= count+1;
    fprintf("Referenced interferogram %d/%d saved. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
end


end

