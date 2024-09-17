%% Load Page from HDF5 File

function [Page,Grid,PrimaryDate,SecondaryDate]= loadPage(...
    h5filename,Flag,Mission,Track,k)

arguments
    h5filename
    Flag {mustBeMember(Flag,["L1","L2","closureMask","L3","SBAS"])}
    Mission
    Track
    k= 1;
end

if ischar(Mission) || iscellstr(Mission) %#ok<ISCLSTR>
    Mission= string(Mission);
end


% Grid
Grid= h5.readGrid(h5filename,'/grid');

% Dates
[PrimaryDates,SecondaryDates]= io.loadDates(h5filename,Flag,Mission,Track);

if isempty(PrimaryDates)
    error('No data to load')
end

PrimaryDate= PrimaryDates(k);
if strcmpi(Flag,"L3") || strcmpi(Flag,"SBAS")
    SecondaryDate= [];
else
    SecondaryDate= SecondaryDates(k);
end

switch Flag
    case "L1"
        basepath= '/interferogram/L1-stitched';
        name= 'data';
    case "L2"
        basepath= '/interferogram/L2-closureCorrected';
        name= 'data';
    case "closureMask"
        basepath= '/interferogram/L2-closureCorrected';
        name= 'closureMask/mask';
    case "L3"
        basepath= '/timeseries/L3-displacement';
        name= 'data';
    case "SBAS"
        basepath= '/timeseries/L3-displacement';
        name= 'SBAS';
    otherwise
        error('Level flag not supported')
end

trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

% Read from HDF5 file
Page= h5.readPage(h5filename,path,name,k);

end




