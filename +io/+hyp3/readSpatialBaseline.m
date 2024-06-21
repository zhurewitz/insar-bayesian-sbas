%% Read Spatial Baseline

function baseline= readSpatialBaseline(dir,name)

filename= fullfile(dir,name,strcat(name,'.txt'));

S= readlines(filename);

I= contains(S,'Baseline: ');
baseline= str2double(extractAfter(S(I),'Baseline: '));

end
