%% Write 2D Inf
% Writes a 2D matrix or 3D stack to a dataset with infinite size in the 3rd
% dimension to an HDF5 file, creating the dataset if necessary

function write2DInf(filename,path,name,data,k,ChunkSize,Deflate)

arguments
    filename
    path
    name
    data
    k
    ChunkSize= [300 300 1];
    Deflate= 3;
end

if ~h5.exist(filename)
    error('File does not exist')
end


%% Create Dataset

Size= size(data);
Size(3)= Inf;

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


%% Write Data

start= [1 1 k];

if ismatrix(data)
    count= [size(data) 1];
else
    count= size(data);
end

h5write(filename,fullfile(path,name),data,start,count)

end







