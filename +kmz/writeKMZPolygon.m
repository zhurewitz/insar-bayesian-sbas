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

if ~exist(path,'dir') && path ~= ""
    mkdir(path)
end

Document= struct;
Document.name= name;
Document.Placemark.name= name;

if ~any(isnan(polyLong))
    coords= [polyLong; polyLat; zeros(size(polyLong))];

    % Format coordinate string
    coordstr= sprintf("%0.15f,%0.15f,%0.15f ",coords);

    % Add to struct
    Document.Placemark.Polygon.outerBoundaryIs.LinearRing.coordinates= coordstr;

else
    [Istart,Iend,Value]= utils.uniqueRegions(~isnan(polyLong));
    
    Istart= Istart(Value);
    Iend= Iend(Value);
    
    for i= 1:length(Istart)
        I= Istart(i):Iend(i);

        coords= [polyLong(I); polyLat(I); zeros(1,length(I))];

        % Format coordinate string
        coordstr= sprintf("%0.15f,%0.15f,%0.15f ",coords);

        % Add to struct
        Document.Placemark.MultiGeometry.Polygon(i).outerBoundaryIs.LinearRing.coordinates= coordstr;
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



