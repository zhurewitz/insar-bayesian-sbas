%% D3.CHUNKINDICES

function [J,I,K]= chunkIndices(ChunkSize,j,i,k,Size)

arguments
    ChunkSize
    j= 1;
    i= 1;
    k= 1;
    Size= [];
end

[start,count]= d3.chunkStartCount(ChunkSize,j,i,k,Size);

J= start(1)+ (0:count(1)-1);
I= start(2)+ (0:count(2)-1);
K= start(3)+ (0:count(3)-1);

end
