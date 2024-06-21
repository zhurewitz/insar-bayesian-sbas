%% Interferogram LOS Displacement -- ARIA Format

function [LOSdisplacement,frameLat,frameLong,mask]=...
    readLOSdisplacement(filename)

% Meta data
metaData= io.aria.shortMetaData2(filename);

% Read unwrapped phase data
unwrappedPhase= single(ncread(filename,'/science/grids/data/unwrappedPhase'));
unwrappedPhase= unwrappedPhase';

if metaData.TimeForward
    unwrappedPhase= unwrappedPhase*-1;
end

[frameLat,frameLong]= io.aria.readLatLong(filename);

coherence= io.aria.readCoherence(filename);
connComp= io.aria.readConnectedComponents(filename);

% Radar Wavelength (mm)
switch metaData.Mission
    case "S1"
        wavelength= 55.46576157;
    otherwise
        wavelength= 55.46576157;
end

% LOS displacement (mm)
LOSdisplacement= wavelength/(4*pi)* unwrappedPhase; 
% Seems that there should NOT be a minus sign to be oriented in upwards
% direction, although I thought there should have been

% Source:
% https://asf.alaska.edu/how-to/data-recipes/interpreting-an-unwrapped-interferogram-creating-a-deformation-map/


% Mask by coherence value
LOSdisplacement(connComp ~= mode(connComp,'all') | coherence < .5)= nan;


% Interferogram mask -- land pixels within the interferogram frame
outside= zeros(size(LOSdisplacement));
CC= bwconncomp(isnan(LOSdisplacement));
[~,I]= max(cellfun(@length,CC.PixelIdxList));
pixlist= cell2mat(CC.PixelIdxList(I));
outside(pixlist)= 1;

mask= ~outside;

end