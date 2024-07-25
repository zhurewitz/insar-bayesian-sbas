%% Interferogram LOS Displacement -- ARIA Format

function [LOSdisplacement,frameLat,frameLong,coherence,connComp]=...
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
coherence= flip(coherence);
connComp= io.aria.readConnectedComponents(filename);
connComp= flip(connComp);

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

% Flip to orient upwards
frameLat= flip(frameLat);
LOSdisplacement= flip(LOSdisplacement);

end