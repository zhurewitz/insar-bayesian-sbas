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

% Filenames
metaData.Filename= strcat(name,ext);
metaData.Fullname= filelist;

end


