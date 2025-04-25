%% Write Chunk
% Writes a 2D chunk to an HDF5 file, creating the dataset if necessary

function writeChunk2D(filename,path,name,data,j,i,ChunkSize,Size,Deflate)

arguments
    filename
    path
    name
    data
    j
    i
    ChunkSize
    Size
    Deflate= 3;
end

if ~h5.exist(filename)
    error('File does not exist')
end


%% Create Dataset

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
    h5create(filename,fullfile(path,name),Size(1:2),'ChunkSize',ChunkSize(1:2),...
        DatatypeParameters{:},DeflateParameters{:})
end


%% Write Data

[start,count]= h5.chunkStartCount(ChunkSize,Size,j,i);

h5write(filename,fullfile(path,name),data,start(1:2),count(1:2))

end







