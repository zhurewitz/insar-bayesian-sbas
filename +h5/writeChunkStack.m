%% Write Chunk Stack
% Writes a stack of chunks to a dataset with infinite size in the 3rd
% dimension to an HDF5 file, creating the dataset if necessary

function writeChunkStack(filename,path,name,data,j,i,ChunkSize,Size,Deflate)

arguments
    filename
    path
    name
    data
    j
    i
    ChunkSize= [200 200 2];
    Size= [];
    Deflate= 3;
end


%% Create Dataset

Size(3)= Inf;

switch class(data)
    case 'double'
        Datatype= 'double';
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
if ~h5.exist(filename) || ~h5.exist(filename,path,name)
    h5create(filename,fullfile(path,name),Size,'ChunkSize',ChunkSize,...
        DatatypeParameters{:},DeflateParameters{:})
end


%% Write Data

[start,count]= h5.chunkStartCount(ChunkSize,Size,j,i);

count(3)= size(data,3);

h5write(filename,fullfile(path,name),data,start,count)

end







