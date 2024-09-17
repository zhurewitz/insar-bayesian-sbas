%% Load Dates from H5 File

function [primaryDate,secondaryDate]= loadDates(filename,Flag,Mission,Track)

switch Flag
    case 'L1'
        basepath= '/interferogram/L1-stitched';
    case 'closureMask'
        basepath= '/interferogram/L2-closureCorrected';
    case 'L2'
        basepath= '/interferogram/L2-closureCorrected';
    case 'L3'
        basepath= '/timeseries/L3-displacement';
    case 'SBAS'
        basepath= '/timeseries/L3-displacement';
    otherwise
        error('Flag not found')
end

trackstr= strcat(Mission,'-',string(Track));

switch Flag
    case 'closureMask'
        path= fullfile(basepath,trackstr,'closureMask');
    otherwise
       path= fullfile(basepath,trackstr);
end

if strcmpi(Flag,"L3") || strcmpi(Flag,"SBAS")
    primaryDate= h5.read(filename,path,'date');
    secondaryDate= [];
else
    primaryDate= h5.read(filename,path,'primaryDate');
    secondaryDate= h5.read(filename,path,'secondaryDate');
end

end




