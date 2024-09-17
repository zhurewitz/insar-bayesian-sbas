%% H5.CHUNKINDICES

function [J,I]= chunkIndices(ChunkSize,Size,j,i)

arguments
    ChunkSize
    Size
    j
    i
end

[start,count]= h5.chunkStartCount(ChunkSize,Size,j,i);

J= start(1)+ (0:count(1)-1);
I= start(2)+ (0:count(2)-1);

end

