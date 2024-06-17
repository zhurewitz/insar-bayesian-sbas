%% Read Coherence

function connectedComponents= readConnectedComponents(filename)

connectedComponents= ncread(filename,'/science/grids/data/connectedComponents')';

end