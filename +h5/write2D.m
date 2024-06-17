%% Write 2D
% Writes a 2D matrix to an HDF5 file, creating the dataset if necessary.
% Includes chunking, compression, and data type handling

function write2D(filename,path,name,data,ChunkSize,Deflate)

arguments
    filename
    path
    name
    data
    ChunkSize= [300 300];
    Deflate= 3;
end

if ~h5.exist(filename)
    error('File does not exist')
end


%% Create Dataset

Size= size(data);

switch class(data)
    case 'double'
        FillValue= nan;
    case 'single'
        Datatype= 'single';
        FillValue= nan(1,'single');
    case 'logical'
        data= uint8(data);
        Datatype= 'uint8';
        FillValue= '';
        Deflate= 9;
    otherwise
        Datatype= '';
        FillValue= '';
end


DatatypeParameters= {};
if ~isempty(Datatype)
    DatatypeParameters= {'Datatype',Datatype};
end
if ~isempty(FillValue)
    DatatypeParameters= [DatatypeParameters 'FillValue' FillValue];
end

DeflateParameters= {};
if Deflate > 0
    DeflateParameters= {'Deflate',Deflate,'Shuffle',true,'Fletcher32',true};
end

% Create dataset
if ~h5.exist(filename,path,name)
    h5create(filename,fullfile(path,name),Size,'ChunkSize',ChunkSize,...
        DatatypeParameters{:},DeflateParameters{:})
end


% Write Data
h5write(filename,fullfile(path,name),data)

end







