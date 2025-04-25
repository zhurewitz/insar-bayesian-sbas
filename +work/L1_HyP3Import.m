%% L1 Processing - Save interferograms to stack

load input.mat

ChunkSize= [200 200 1];

InterferogramFile= fullfile(workdir,"L1interferogram.h5");
CoherenceFile= fullfile(workdir,"L1coherence.h5");



%% Grid

commonGrid= utils.createGrid(LatLim,LongLim,1/1200);
GridLong= commonGrid.Long;
GridLat= commonGrid.Lat;
Size= commonGrid.Size;
clear commonGrid



%% Choose Interferograms

% Read file name metadata
[~,filelist]= io.listDirectory(datadir);
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

    
    %% Load and Stitch

    % Names of frames for this interferogram
    frameNames= frameTable.Fullname(...
        frameTable.PrimaryDate == PrimaryDate(k) & ...
        frameTable.SecondaryDate == SecondaryDate(k), :);
    
    [LOS,COH]= io.hyp3.stitchInterferograms(frameNames,GridLong,GridLat);
    
    
    


    %% Save
    
    z= [PrimaryDate(k) SecondaryDate(k)];

    % Save
    d3.writePage(InterferogramFile,LOS,k,GridLong,GridLat,z,ChunkSize)
    d3.writePage(CoherenceFile,COH,k,GridLong,GridLat,z,ChunkSize)
    
    
    fprintf("Interferogram %d/%d (%s - %s) saved. Elapsed time %0.1f min\n",...
        k,Npairs,string(PrimaryDate(k)),string(SecondaryDate(k)),toc/60)
    
    if mod(k,10) == 0
        fprintf("1 second pause\n")
        pause(1)
    end
end




