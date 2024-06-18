%% Workflow Template

% *** User input ***

% Directories
datadirs= ["/full/path/to/data1","/full/path/to/data2"]; 
savedir= "/full/path/to/save/directory/";

% Bounds
% LatLim= [minLat maxLat];
% LongLim= [minLong maxLong];
% * Uncomment and set latitude and longitude bounds manually in the
% previous two lines

% Reference area polygon
% *Load vectors referenceLongitude and referenceLatitude

% Coastline polygon
% *Load vectors coastlineLongitude and coastlineLatitude

% Load OpenTopography API key
% *Load APIkey as string

% Output filenames
L1filename= fullfile(savedir,'processingStoreL1.h5');
L2filename= fullfile(savedir,'processingStoreL2.h5');
L3filename= fullfile(savedir,'processingStoreL3.h5');



%% Create File and Save Grid

if ~exist(savedir,'dir')
    mkdir(savedir)
end

% Grid metadata
flow.generateGrid(L1filename,LongLim,LatLim,referenceLongitude,...
    referenceLatitude, coastlineLongitude,coastlineLatitude);
flow.generateGrid(L2filename,LongLim,LatLim);
flow.generateGrid(L3filename,LongLim,LatLim);

% Import DEM
if ~isempty(APIkey)
    io.importElevation([L1filename,L2filename,L3filename],APIkey)
end



%% Level-1 Processing -- Stitch Interferograms and Save to Common Grid

for k= 1:length(datadirs)
    datadir= datadirs(k);
    
    if ~exist(datadir,'dir')
        error('Data directory not found')
    end

    % List interfograms in directory
    [~,filelist]= io.aria.listDirectory(datadir);

    % Import interferograms
    flow.importInterferogramFrames(L1filename,filelist);
end



%% Level-2 Processing -- Process Phase Closure Mask and Correct Interferograms

flow.processClosureMask(L1filename,L2filename);

flow.applyClosureCorrection(L1filename,L2filename);



%% Level-3 Processing -- Estimate Displacement Timeseries

flow.processDisplacementTimeseries(L2filename,L3filename)

