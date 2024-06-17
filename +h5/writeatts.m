%% H5 Write Attributes
% Writes multiple attributes to a single dataset

function writeatts(filename,path,name,attname,attvalue)

arguments
    filename
    path
    name
end

arguments (Repeating)
    attname
    attvalue
end

if ~h5.exist(filename)
    error('File does not exist')
end

if ~h5.exist(filename,path,name)
    error('Group or dataset does not exist')
end

for i= 1:length(attname)
    h5writeatt(filename,fullfile(path,name),attname{i},attvalue{i})
end

end

