%% Write Vector with Unlimited Size to HDF5 File
% A high-level function to automatically handle creation and writing,
% datetimes, logicals, NaN default fill values, and Inf dataset size.


function writeInf(filename,path,name,data,ChunkSize)

arguments
    filename
    path
    name
    data
    ChunkSize= 1000;
end

% Ensure text data is in string format
if ischar(data) || iscellstr(data) %#ok<ISCLSTR>
    data= string(data);
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

ChunkCell= {'Chunksize',ChunkSize};

DataTypeCell= {};
if ~isempty(DataType)
    DataTypeCell= {'Datatype',DataType};
end

FillCell= {};
if ~isempty(FillValue)
    FillCell= {'Fillvalue',FillValue};
end



%% Create and Write

if ~h5.exist(filename) || ~h5.exist(filename,path,name)
    h5create(filename,fullfile(path,name),Inf,...
        ChunkCell{:},DataTypeCell{:},FillCell{:})
end

if ~h5.exist(filename,path,name)
    error('Dataset was not created')
end

h5write(filename,fullfile(path,name),data,1,length(data))

end



