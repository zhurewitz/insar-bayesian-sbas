%% Generate and Save Ocean Mask

function generateOceanMask(workdir,h5filename)

% Read grid from h5 file
commonGrid= h5.readGrid(h5filename,'/grid');


wvsdir= fullfile(workdir,wvsname);
zipname= fullfile(workdir,strcat(wvsname,'.zip'));

if ~exist(zipname,'file') && ~exist(wvsdir,'dir')
    fprintf('Downloading World Vector Shoreline (WVS)...\n')
    websave(zipname,...
        'http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-bin-2.3.7.zip')
    fprintf('Download complete.\n')
end

if exist(zipname,'file') && ~exist(wvsdir,'dir')
    unzip(zipname,wvsdir)
    delete(zipname)
    fprintf('WVS data unzipped and zip file deleted.\n')
end

% Binary WVS File -- "High" resolution
% From GSHHG homepage (https://www.soest.hawaii.edu/pwessel/gshhg/)
% f: full resolution: Original (full) data resolution.
% h: high resolution: About 80 % reduction in size and quality.
% i: intermediate resolution: Another ~80 % reduction.
% l: low resolution: Another ~80 % reduction.
% c: crude resolution: Another ~80 % reduction.
binaryWVSFilename= fullfile(wvsdir,'/gshhs_h.b');

% Read binary WVS file
coastlineStruct= utils.readBinaryWVSFile(binaryWVSFilename);



%% Find Intersecting Polygons

% Allocate memory for multi-polygon representing all coastline polygons
% which might intersect
px= nan(1e7,1);
py= nan(1e7,1);

k= 1;
for i= 1:length(coastlineStruct)
    C= coastlineStruct(i);
    
    % If the bounding boxes overlap, add polygon
    if bboxIntersect(commonGrid,C.west,C.east,C.south,C.north)
        I= k+ (0:C.N-1);
        
        px(I)= C.long; 
        py(I)= C.lat; 
        
        k= k+ C.N+ 1; % Move indices
        % Note: the +1 allows for a NaN value between each polygon,
        % separating them
    end
end

% Crop to actual memory used
px= px(1:k);
py= py(1:k);



%% Make Ocean/Water Mask and Save

OCEAN= ~inpolygonfastGrid(commonGrid.Long,commonGrid.Lat,px,py);

path= '/grid/';
h5.write(h5filename,path,'oceanMask',uint8(OCEAN),'Datatype','uint8',...
        'ChunkSize',[600 600],'Deflate',9,'Shuffle',true,'Fletcher32',true)



end




function TF= bboxIntersect(grid,West,East,South,North)

rect1= [grid.LongLim(1) grid.LatLim(1) diff(grid.LongLim) diff(grid.LatLim)];
rect2= [West,South,East-West,North-South];

TF= abs(rectint(rect1,rect2)) > 1e-10;

end