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
    otherwise
        error('Flag not found')
end

S= h5info(filename,path);

[~,Names]= fileparts(string({S.Groups.Name}'));

A= split(Names,'-');

Missions= unique(A(:,1));

Tracks= unique(str2double(A(:,2)));

end
