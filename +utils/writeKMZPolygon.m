%% Write KMZ Polygon
% Writes a polygon to a Google Earth KML/KMZ file

function writeKMZPolygon(filename,polyLong,polyLat,name)

arguments
    filename
    polyLong (1,:)
    polyLat (1,:)
    name= "Polygon";
end

[path,~,ext]= fileparts(filename);

if ~strcmp(ext,'.kmz') && ~strcmp(ext,'.kml')
    error('Filename %s does not have required .kmz or .kml extension')
end

if ~exist(path,'dir')
    mkdir(path)
end

coords= [polyLong; polyLat; zeros(size(polyLong))];

% Format coordinate string
coordstr= sprintf("%g,%g,%g ",coords);

% Add to struct
Document= struct;
Document.name= name;
Document.Placemark.name= name;
Document.Placemark.Polygon.outerBoundaryIs.LinearRing.coordinates= coordstr;



%% Write KML/KMZ File

if strcmp(ext,'.kmz')
    % Write KML file to temporary directory
    tmpdir= tempname;
    mkdir(tmpdir)
    kmlfile= fullfile(tmpdir,'doc.kml');
    writestruct(Document,kmlfile,'FileType','xml','StructNodeName','Document')

    % Zip file
    [~,fname,~]= fileparts(filename);
    zipfile= fullfile(tmpdir,strcat(fname,'.zip'));
    zip(zipfile,kmlfile)

    % Move to requested KMZ file
    movefile(zipfile,filename)

    % Delete temporary file and directory
    delete(kmlfile)
    rmdir(tmpdir)

else
    % Write KML directly
    writestruct(Document,filename,'FileType','xml','StructNodeName','Document')
    
end

end



