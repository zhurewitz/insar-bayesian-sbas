%% Workflow Template

% *** User input ***

% Data directories
datadirs= ["/full/path/to/data1","/full/path/to/data2"]; 

% Work/Save directory
workdir= "/full/path/to/work/directory/";

% Bounds
% LatLim= [minLat maxLat];
% LongLim= [minLong maxLong];
% * Uncomment and set latitude and longitude bounds manually in the
% previous two lines

% Reference area polygon
% *Load vectors referenceLongitude and referenceLatitude

% OpenTopography API key
APIkey= "my11111API22222key33333";

% Output filenames
L1filename= fullfile(workdir,'processingStoreL1.h5');
L2filename= fullfile(workdir,'processingStoreL2.h5');
L3filename= fullfile(workdir,'processingStoreL3.h5');



%% Create File and Save Grid

if ~exist(workdir,'dir')
    mkdir(workdir)
end

% Grid metadata
flow.generateGrid(L1filename,LongLim,LatLim,referenceLongitude,...
    referenceLatitude);
flow.generateGrid(L2filename,LongLim,LatLim);
flow.generateGrid(L3filename,LongLim,LatLim);

% Import DEM
if ~isempty(APIkey)
    io.importElevation([L1filename,L2filename,L3filename],APIkey)
end

% Generate ocean mask from World Vector Shoreline data
io.generateOceanMask(workdir,L1filename);



%% Level-1 Processing -- Stitch Interferograms and Save to Common Grid

for k= 1:length(datadirs)
    datadir= datadirs(k);
    
    if ~exist(datadir,'dir')
        error('Data directory not found')
    end

    % List interfograms in directory
    [~,filelist]= io.listDirectory(datadir);

    % Import interferograms
    flow.importInterferogramFrames(L1filename,filelist);
end



%% Level-2 Processing -- Process Phase Closure Mask and Correct Interferograms

flow.processClosureMask(L1filename,L2filename);

flow.applyClosureCorrection(L1filename,L2filename);



%% Level-3 Processing -- Estimate Displacement Timeseries

flow.processDisplacementTimeseries(L2filename,L3filename)

