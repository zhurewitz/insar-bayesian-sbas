%% Read MetaData - ARIA Format

function metaData= readMetaData(filename)

[~,name,ext]= fileparts(filename);

T= table;

% Parse filename
S= split(name,'-');

% Mission
T.Mission= S{1};

% Radar wavelength band
if strcmp(S{1},'S1')
    T.Band= 'C';
end

% Track
T.Track= str2double(S{5});

% Direction
T.Direction= S{3};

% Dates
[dates,timeForward]= io.aria.interferogramDates(filename);
T.PrimaryDate= dates(1);
T.SecondaryDate= dates(2);
T.TemporalBaseline= days(diff(dates));

% Read perpendicular baseline
T.SpatialBaseline= mean(io.aria.readBaseline(filename),'all');

% Read bounding box information
[Lat,Long]= io.aria.readLatLong(filename);
T.BoundingBox= [min(Long) max(Long) min(Lat) max(Lat)];

T.dL= abs(diff(Long(1:2)));

% Polygon
V= io.aria.readBoundingPolygon(filename);
T.Polyshape= polyshape(V(1,:),V(2,:));

% Time direction
T.TimeForward= timeForward;

% Read wavelength
T.Wavelength_mm= 1000*ncread(filename,'science/radarMetaData/wavelength');

% Filenames
T.Filename= strcat(name,ext);
T.Fullname= filename;


metaData= T;
