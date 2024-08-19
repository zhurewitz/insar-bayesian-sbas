%% KMZ.WRITEPOLYSHAPE
% Writes a polyshape to a Google Earth KML/KMZ file

function writePolyshape(filename,pshape,name)

arguments
    filename
    pshape
    name= "Polygon";
end

[path,~,ext]= fileparts(filename);

if ~strcmp(ext,'.kmz') && ~strcmp(ext,'.kml')
    error('Filename %s does not have required .kmz or .kml extension')
end

if ~exist(path,'dir') && path ~= ""
    mkdir(path)
end

Document= struct;
Document.name= name;
Document.Placemark.name= name;

% Separate the polyshape into regions to add separately
REGIONS= regions(pshape);

for i= 1:length(REGIONS)
    r= REGIONS(i);
    
    % Add the Outer Boundary
    OUT= rmholes(r);
    
    [x,y]= boundary(OUT);
    Document.Placemark.MultiGeometry.Polygon(i).outerBoundaryIs.LinearRing.coordinates= ...
        kmz.coordinates(x,y);
    
    % Add the holes as Inner Boundaries
    HOLES= holes(r);
    
    for j= 1:length(HOLES)
        IN= HOLES(j);
        
        [x,y]= boundary(IN);
        Document.Placemark.MultiGeometry.Polygon(i).innerBoundaryIs(j).LinearRing.coordinates= ...
            kmz.coordinates(x,y);
    end
end


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



