%% HyP3 Read LOS Displacement

function [LOS,frameLat,frameLong]= readLOSDisplacement2(filename)

[~,name,ext]= fileparts(filename);

if ext == ""
    filename= fullfile(filename,strcat(name,"_unw_phase.tif"));
end

[UNW,frameLat,frameLong]= io.hyp3.readGeoTIFF(filename);

wavelength= 55.46576157;

LOS= -UNW*wavelength/(4*pi);

LOS(LOS == 0)= nan;

end

