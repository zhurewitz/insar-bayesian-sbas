%% Write a Scalar to HDF5 File
% A high-level function to automatically handle creation and writing,
% datetimes, logicals, NaN default fill values, and Inf dataset sizes. For
% scalars only


function writeScalar(filename,path,name,data,DataSetSize,start)

arguments
    filename
    path
    name
    data
    DataSetSize= [];
    start= 1;
end

if ~h5.exist(filename)
    error('File does not exist')
end


% Ensure text data is in string format
if ischar(data) || iscellstr(data) %#ok<ISCLSTR>
    data= string(data);
end

if ~isscalar(data)
    error('Data is not a scalar value')
end
if ~isscalar(start)
    error('Start is not a scalar value')
end


if isempty(DataSetSize)
    DataSetSize= 1;
end

% Chunk Size
if isinf(DataSetSize)
    % Default chunk size for an Inf x 1 array (such as datetimes
    % pairing with an M x N x Inf data array) is 1000
    ChunkSize= 1000;
else
    ChunkSize= [];
end


%% Data Type 

if isa(data,'single')
    DataType= 'single';
    FillValue= nan(1,'single');
elseif isa(data,'double')
    DataType= 'double';
    FillValue= nan;
elseif isa(data,'datetime')
    DataType= 'string';
    FillValue= [];
    data= h5.dateString(data);
elseif isa(data,'logical')
    DataType= 'uint8';
    FillValue= [];
    data= uint8(data);
else
    DataType= [];
    FillValue= [];
end


%% Input Arguments

ChunkCell= {};
if ~isempty(ChunkSize)
    ChunkCell= {'Chunksize',ChunkSize};
end

DataTypeCell= {};
if ~isempty(DataType)
    DataTypeCell= {'Datatype',DataType};
end

FillCell= {};
if ~isempty(FillValue)
    FillCell= {'Fillvalue',FillValue};
end



%% Create and Write

if ~h5.exist(filename,path,name)
    h5create(filename,fullfile(path,name),DataSetSize,...
        ChunkCell{:},DataTypeCell{:},FillCell{:})
end

if ~h5.exist(filename,path,name)
    error('Dataset was not created')
end

h5write(filename,fullfile(path,name),data,start,1)

end



