%% d3.write
% Writes a datacube or portion of a datacube to a dataset with infinite
% size in all dimensions to an HDF5 file, creating the dataset if necessary

function write(filename,data,J,I,K,ChunkSize)

arguments
    filename
    data {mustBeNumericOrLogical}
    J= [];
    I= [];
    K= [];
    ChunkSize= [200 200 1];
end

%% Create Dataset

Size= [Inf Inf Inf];

switch class(data)
    case 'logical'
        data= uint8(data);
        Datatype= 'uint8';
        FillValue= zeros(1,"uint8");
        Deflate= 9;
    otherwise
        data= single(data);
        Datatype= 'single';
        FillValue= nan(1,'single');
        Deflate= 3;
end

DatatypeParameters= {'Datatype',Datatype, 'FillValue', FillValue};
DeflateParameters= {'Deflate',Deflate,'Shuffle',true,'Fletcher32',true};

% Create dataset
if ~h5.exist(filename) || ~h5.exist(filename,"/","data")
    h5create(filename,"/data",Size,'ChunkSize',ChunkSize,...
        DatatypeParameters{:},DeflateParameters{:})
end


%% Write Data

[start, count, stride]= d3.writeStartCountStride3D(data,J,I,K);

h5write(filename,"/data",data,start,count,stride)



end
