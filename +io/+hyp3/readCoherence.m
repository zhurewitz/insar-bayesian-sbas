%% HyP3 Read Coherence

function [COH,frameLat,frameLong]= readCoherence(filename)

[~,name,ext]= fileparts(filename);

if ext == ""
    filename= fullfile(filename,strcat(name,"_corr.tif"));
end

[COH,frameLat,frameLong]= io.hyp3.readGeoTIFF(filename);

end

