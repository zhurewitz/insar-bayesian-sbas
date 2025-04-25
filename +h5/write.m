%% H5 Write
% Robust wrapper for HDF5 write including creation and datetime conversion

function write(filename,path,name,data,varargin)

arguments
    filename
    path
    name
    data= [];
end

arguments (Repeating)
    varargin
end


if isvector(data)
    Size= length(data);
else
    Size= size(data);
end

if ~h5.exist(filename) || ~h5.exist(filename,path,name)
    h5create(filename,fullfile(path,name),Size,varargin{:})
end

if isdatetime(data)
    data= h5.dateString(data);
end

h5write(filename,fullfile(path,name),data)

end



