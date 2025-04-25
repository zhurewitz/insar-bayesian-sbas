%% L1 Processing - Save interferograms to stack

load input.mat

ChunkSize= [200 200 1];


InterferogramFile= fullfile(workdir,"L1interferogram.h5");
CoherenceFile= fullfile(workdir,"L1coherence.h5");
ConnCompFile= fullfile(workdir,"L1connectedComponent.h5");



%% Grid

commonGrid= utils.createGrid(LatLim,LongLim,1/1200);
GridLong= commonGrid.Long;
GridLat= commonGrid.Lat;
Size= commonGrid.Size;
clear commonGrid



%% Choose Interferograms

% Read file name metadata
[~,filelist]= io.aria.listDirectory(datadir);
filelist= string(filelist);
frameTable= io.shortMetaData(filelist);

% Crop out all files which are not part of this Mission/Track
I= strcmpi(frameTable.Mission,Mission) & frameTable.Track == Track;
frameTable= frameTable(I,:);

% Find unique interferograms
UniquePairs= unique([frameTable.PrimaryDate frameTable.SecondaryDate],'rows');
PrimaryDate= UniquePairs(:,1);
SecondaryDate= UniquePairs(:,2);
clear UniquePairs

% Keep interferogram pairs which meet the date limit requirements
I= PrimaryDate >= DateLim(1) & SecondaryDate <= DateLim(2);
PrimaryDate= PrimaryDate(I);
SecondaryDate= SecondaryDate(I);

Npairs= length(PrimaryDate);



%% Import Interferograms

if ~exist(workdir,'dir')
    mkdir(workdir)
end


fprintf('Beginning import of %d frames making up %d interferograms\n',height(frameTable),Npairs)

tic
for k= 1:Npairs
    
    % Check to see if interferogram has already been processed
    [~,~,DatePairs]= d3.readXYZ(InterferogramFile);
    
    if ~isempty(DatePairs) && any(all(DatePairs == [PrimaryDate(k) SecondaryDate(k)],2))
        fprintf("Interferogram %d/%d already written, continuing. \n",...
            k,Npairs)
        continue
    end
    
    


    
    %% Load Interferogram

    % Names of frames for this interferogram
    frameNames= frameTable.Fullname(...
        frameTable.PrimaryDate == PrimaryDate(k) & ...
        frameTable.SecondaryDate == SecondaryDate(k), :);
    
    BoundingPolygon= polyshape(LongLim([1 2 2 1 1]),LatLim([1 1 2 2 1]));
    
    
    % Find polygon with maximum intersecting area with the bounding box
    
    Nframes= length(frameNames);
    IntersectionArea= zeros(Nframes,1);
    for i= 1:Nframes
        [vx,vy]= io.aria.readBoundingPolygon(frameNames(i));
        Polygon= polyshape(vx,vy);
        IntersectionArea(i)= area(intersect(BoundingPolygon,Polygon));
    end
    
    [MaxArea,ia]= max(IntersectionArea);
    
    
    
    %*********HARDCODE ALERT**********
    if MaxArea < 1.5
        fprintf("Interferogram %d/%d (%s - %s) is missing the key frame, cannot load\n",...
            k,Npairs,string(PrimaryDate(k)),string(SecondaryDate(k)))
        
        continue
    end
    %*********HARDCODE ALERT**********
    
    OnlyFilename= frameNames(ia);
    
    % Read data
    [displacementLOS,frameLat,frameLong,coherence,connComp]=...
        io.readLOSdisplacement(OnlyFilename);
    
    
    

    %% Place on Common Grid
    
    [Iax,Iay,Ibx,Iby]= utils.insertionIndices(GridLong,GridLat,frameLong,frameLat);
    
    LOS= nan(Size,'single');
    LOS(Iay,Iax)= displacementLOS(Iby,Ibx);

    COH= nan(Size,'single');
    COH(Iay,Iax)= coherence(Iby,Ibx);

    CON= nan(Size,'single');
    CON(Iay,Iax)= connComp(Iby,Ibx);
    

    


    %% Save
    
    z= [PrimaryDate(k) SecondaryDate(k)];

    % Save
    d3.writePage(InterferogramFile,LOS,k,GridLong,GridLat,z,ChunkSize)
    d3.writePage(CoherenceFile,COH,k,GridLong,GridLat,z,ChunkSize)
    d3.writePage(ConnCompFile,CON,k,GridLong,GridLat,z,ChunkSize)
    
    
    fprintf("Interferogram %d/%d (%s - %s) saved. Elapsed time %0.1f min\n",...
        k,Npairs,string(PrimaryDate(k)),string(SecondaryDate(k)),toc/60)
    
    if mod(k,10) == 0
        fprintf("1 second pause\n")
        pause(1)
    end
end




