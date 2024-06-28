%% Reference Area from Multiple KMZ Files

% *** User Input ***

workdir= "/path/to/work/directory";

KMZlist= ["/path/to/first/file.kmz" "/path/to/second/file.kmz"];

% *** End User Input ***




%% Load Polygons

referenceAreaFilename= fullfile(workdir,'referenceArea.mat');

referenceLongitude= [];
referenceLatitude= [];

for i= 1
    kmzfilename= KMZlist(i);

    try
        [polyLat,polyLong]= utils.readKMZPolygon(kmzfilename);
        
        if isempty(referenceLongitude)
            referenceLongitude= polyLong;
            referenceLatitude= polyLat;
        else
            referenceLongitude= [referenceLongitude nan polyLong]; %#ok<AGROW>
            referenceLatitude= [referenceLatitude nan polyLat]; %#ok<AGROW>
        end
    catch
        warning('Something went wrong reading file %s',kmzfilename)
    end
end

save(referenceAreaFilename,"referenceLatitude","referenceLongitude")


