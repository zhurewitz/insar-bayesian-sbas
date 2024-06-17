%% Workflow

% User input

savedir= "/Volumes/Zel's Work Drive/Work/CV-ARIA5-BOTH/";
datadirs= "/Volumes/Zel's Work Drive/Data/InSAR/CV-ARIA-BOTH/";

% Note: Multiple data directories can be specified with the syntax
% datadirs= ["/path/to/data1" "/path/to/data2"]


% Grid
LatLim= [34.75 37.75];
LongLim= [-122 -118];

% Reference area polygon
load Data/refLatLong.mat
referenceLongitude= refLong;
referenceLatitude= refLat;

% Coastline polygon
load Data/WESTCOAST.mat
coastlineLongitude= WESTCOAST.Vertices(:,1);
coastlineLatitude= WESTCOAST.Vertices(:,2);

h5filename= fullfile(savedir,'processingStore.h5');

load Data/APIkey.mat



%% Create File and Save Grid

if ~exist(savedir,'dir')
    mkdir(savedir)
end

% Grid metadata
flow.generateGrid(h5filename,LongLim,LatLim,referenceLongitude,...
    referenceLatitude, coastlineLongitude,coastlineLatitude);

% Import DEM
if ~isempty(APIkey)
    io.importElevation(h5filename,APIkey)
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
    flow.importInterferogramFrames(h5filename,filelist);
end



%% Level-2 Processing -- Process Phase Closure Mask and Correct Interferograms

flow.processClosureMask(h5filename);

flow.applyClosureCorrection(h5filename);


%% L3

flow.processDisplacementTimeseries(h5filename)

