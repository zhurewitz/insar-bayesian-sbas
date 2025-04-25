%% d3.write1D
% A high-level function to automatically handle creation, writing,
% datetimes, logicals, and NaN default fill values for a 1D dataset


function write1D(filename,name,data,I,ChunkSize)

arguments
    filename
    name
    data
    I= [];
    ChunkSize= 1000;
end



%% Format Input

% Ensure name is in string format
if ischar(name) || iscellstr(name) %#ok<ISCLSTR>
    name= string(name);
end

% Ensure name begins with /
if extract(name,1) ~= "/"
    name= fullfile("/",name);
end

% Ensure text data is in string format
if ischar(data) || iscellstr(data) %#ok<ISCLSTR>
    data= string(data);
end

% Data type conversion
switch class(data)
    case 'datetime'
        data= h5.dateString(data);
    case 'logical'
        data= uint8(data);
end



%% Create Dataset

if ~h5.exist(filename) || ~h5.exist(filename,name)
    FillValue= [];

    % Fill value selection
    switch class(data)
        case 'double'
            FillValue= nan;
        case 'single'
            FillValue= nan(1,'single');
    end
    
    FillValueParameter= {};
    if ~isempty(FillValue)
        FillValueParameter= {'Fillvalue', FillValue};
    end
    
    DeflateParameters= {};
    if isnumeric(data)
        DeflateParameters= {'Deflate',3,'Shuffle',true,'Fletcher32',true};
    end

    % Create dataset
    h5create(filename,name,Inf,"Datatype",class(data),...
        'Chunksize',ChunkSize,FillValueParameter{:},DeflateParameters{:})
end



%% Write 

if ~h5.exist(filename)
    error('File does not exist')
end

if ~h5.exist(filename,name)
    error('Dataset does not exist')
end

if isempty(I)
    I= 1:length(data);
end

[start,count,stride]= d3.writeStartCountStride1D(data,I);

h5write(filename,name,data,start,count,stride)



end



