%% Read Coherence

function coherence= readCoherence(filename)

coherence= single(ncread(filename,'/science/grids/data/coherence')');

end