%% Read Mission and Track Combinations

function [Missions, Tracks]= readMissionTracks(filename,Flag)

switch Flag
    case 'metaGrid'
        path= '/metaGrid';
    case 'L1'
        path= '/interferogram/L1-stitched';
    case 'closureMask'
        path= '/interferogram/L2-closureCorrected';
    case 'L2'
        path= '/interferogram/L2-closureCorrected';
    case 'L3'
        path= '/timeseries/L3-displacement';
    otherwise
        error('Flag not found')
end

S= h5info(filename,path);

[~,Names]= fileparts(string({S.Groups.Name}'));

A= split(Names,'-');

if isvector(A)
    Missions= A(1);
    Tracks= str2double(A(2));
else
    Missions= unique(A(:,1));
    Tracks= unique(str2double(A(:,2)));
end

end
