%% Read MetaData - ARIA Format

function metaData= shortMetaData2(filelist)

[~,name,ext]= fileparts(filelist);

metaData= table;

Ninf= length(filelist);

% Parse filename
S= reshape(split(name,'-'),[],12);

metaData.ProcessingCenter= repmat("ARIA",length(filelist),1);

% Mission
metaData.Mission= string(S(:,1));

% Radar wavelength band
metaData.Band= repmat("C",Ninf,1);

% Track
metaData.Track= str2double(S(:,5));

% Direction (A/D)
metaData.Direction= S(:,3);

% Dates
[dates,timeForward]= io.aria.interferogramDates(filelist);
metaData.PrimaryDate= dates(:,1);
metaData.SecondaryDate= dates(:,2);
metaData.TemporalBaseline= days(diff(dates,1,2));

% Time direction
metaData.TimeForward= timeForward;

s= S(:,9);
x= nan(Ninf,4);
for i= 1:Ninf
    x(i,:)= sscanf(s(i),"%f%c_%f%c")';
end
west= char(x(:,2)) == 'W';
south= char(x(:,4)) == 'S';
metaData.Longitude= x(:,1).*(-1).^west;
metaData.Latitude= x(:,3).*(-1).^south;

% Version number
metaData.Version= S(:,12);

% Filenames
metaData.Filename= strcat(name,ext);
metaData.Fullname= filelist;

end


