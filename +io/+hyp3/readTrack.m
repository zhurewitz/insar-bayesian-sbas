%% Read Track Number

function [Track,Direction]= readTrack(dir,name)

filename= fullfile(dir,name,strcat(name,'.txt'));

try
    S= readlines(filename);
catch
    warning('Track could not be read from file %s',filename)
    Track= nan;
    Direction= "";
    return
end

I= contains(S,'Reference Granule: ');
referenceGranualeName= extractAfter(S(I),'Reference Granule: ');

S2= split(referenceGranualeName,'_');

absoluteOrbitNumber= str2double(S2(8));

satelliteID= extractAfter(S2(1),'S1');

switch satelliteID
    case 'A'
        Track= mod(absoluteOrbitNumber- 73,175)+ 1;
    case 'B'
        Track= mod(absoluteOrbitNumber- 27,175)+ 1;
    otherwise
        Track= nan;
end

I= contains(S,'Reference Pass Direction: ');
Direction= extract(extractAfter(S(I),'Reference Pass Direction: '),1);

end

