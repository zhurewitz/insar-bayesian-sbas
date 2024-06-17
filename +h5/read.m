%% H5 Read
% Read HDF5 file with error handling and datetime conversion

function data= read(filename,path,name,varargin)

try
    data= h5read(filename,fullfile(path,name),varargin{:});
catch
    data= [];
end

if ~isempty(data) && isstring(data)
    try 
        data= datetime(data,'InputFormat','yyyy-MM-dd');
    catch
    end
end

end

