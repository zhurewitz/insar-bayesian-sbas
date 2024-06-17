%% Interferogram LOS Displacement

function [displacementLOS,frameLat,frameLong,metaData,mask,coherence,connComp]=...
    readLOSdisplacement(filename)

% Meta data
metaData= io.aria.readMetaData(filename);

% Read unwrapped phase data
[unwrappedPhase,frameLat,frameLong]= io.aria.readInterferogram(filename);
if metaData.TimeForward
    unwrappedPhase= unwrappedPhase*-1;
end

coherence= io.aria.readCoherence(filename);
connComp= io.aria.readConnectedComponents(filename);

% Keep only the connected components which are non-zero
IconnComp= ~isnan(connComp) & connComp > 0;% & connComp == mode(connComp(connComp ~= 0));

% Mask
% Note: No longer masking out by coherence value
mask= ~isnan(unwrappedPhase) & IconnComp & ...
    ~isnan(coherence);

% Radar Wavelength (mm)
wavelength= metaData.Wavelength_mm;

% LOS displacement (mm)
displacementLOS= wavelength/(4*pi)* unwrappedPhase; 
% Seems that there should NOT be a minus sign to be oriented in upwards
% direction, although I thought there should have been

% Source:
% https://asf.alaska.edu/how-to/data-recipes/interpreting-an-unwrapped-interferogram-creating-a-deformation-map/

