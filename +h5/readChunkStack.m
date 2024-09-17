%% H5.READCHUNKSTACK

function ChunkStack= readChunkStack(filename,path,name,j,i,ChunkSize,Size)

arguments
    filename
    path
    name
    j= 1;
    i= 1;
    ChunkSize= [];
    Size= [];
end

if isempty(ChunkSize) || isempty(Size)
    [ChunkSize,Size]= h5.chunkSize(filename,path,name);
end

[start,count]= h5.chunkStartCount(ChunkSize,Size,j,i);

ChunkStack= h5.read(filename,path,name,start,count);

end