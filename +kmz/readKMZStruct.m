%% Read KMZ Struct
% Reads a KMZ or KML file as a struct, handling unzipping

function S= readKMZStruct(filename)

[~,~,ext]= fileparts(filename);

switch ext
    case '.kmz'
        kmzfilename= filename;

        % Make a temorary directory
        tmpdir= tempname;
        mkdir(tmpdir)

        % Change extension to .zip and unzip the file
        zipfilename= fullfile(tmpdir,'tmp.zip');
        copyfile(kmzfilename,zipfilename)
        unzip(kmzfilename,tmpdir)

        % Read the doc.kml file
        kmlfilename= fullfile(tmpdir,'doc.kml');
        S= readstruct(kmlfilename,'FileType','xml');

        % Delete the temporary files
        delete(zipfilename)
        delete(kmlfilename)
        rmdir(tmpdir)

    case '.kml'
        % Read the .kml file
        kmlfilename= filename;
        S= readstruct(kmlfilename,'FileType','xml');
        
    otherwise
        error('File must be of type .kml or .kmz')
end

end