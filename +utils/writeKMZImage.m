%% Write Image to Google Earth KMZ

function writeKMZImage(GoogleEarthDir,ImageName,LatLim,LongLim,Image,Mask)

arguments
    GoogleEarthDir
    ImageName
    LatLim
    LongLim
    Image
    Mask= [];
end

if isempty(Mask)
    Mask= ones(size(Image,1:2));
end


% Make temporary directory
tmpdir= tempdir;
imagedir= fullfile(tmpdir,'images');
mkdir(imagedir)
imagefilename= fullfile(imagedir,'/im.png');

% Write image
imwrite(flip(uint8(255*Image)),imagefilename,...
    'Alpha',flip(uint8(255*(Mask))))


%% Generate and Write KML

Document= struct();
Document.name= ImageName;
Document.visibility= 0;
Document.open= 0;


% Make struct for KML GroundOverlay Image
GroundOverlay.name= 'Interferogram';
GroundOverlay.LatLonBox.north= LatLim(2);
GroundOverlay.LatLonBox.south= LatLim(1);
GroundOverlay.LatLonBox.east= LongLim(2);
GroundOverlay.LatLonBox.west= LongLim(1);
GroundOverlay.Icon.href= 'images/im.png';
GroundOverlay.visibility= 1;

LookAt= struct();
LookAt.latitude= mean(LatLim);
LookAt.longitude= mean(LongLim);
LookAt.altitude= 0;
LookAt.range= 130000*max(diff(LatLim),diff(LongLim))^1.3;
LookAt.tilt= 0;


% Add to KML struct
Document.GroundOverlay= GroundOverlay;
Document.LookAt= LookAt;

kmlname= fullfile(tmpdir,strcat(ImageName,'.kml'));
zipname= fullfile(tmpdir,strcat(ImageName,'.zip'));
kmzname= fullfile(GoogleEarthDir,strcat(ImageName,'.kmz'));

writestruct(Document,kmlname,'FileType','xml',...
    'StructNodeName','Document')
zip(zipname,[kmlname imagedir])


if ~exist(GoogleEarthDir,'dir')
    mkdir(GoogleEarthDir)
end
movefile(zipname,kmzname)

delete(kmlname)
delete(imagefilename)
rmdir(imagedir)

end

