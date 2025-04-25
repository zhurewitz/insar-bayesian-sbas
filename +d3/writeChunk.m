%% d3.writeChunk

function writeChunk(filename,data,j,i,k,x,y,z,ChunkSize)

arguments
    filename
    data
    j
    i
    k
    x= [];
    y= [];
    z= [];
    ChunkSize= [200 200 2];
end

[J,I,K]= d3.chunkIndices(ChunkSize,j,i,k);

d3.write(filename,data,J,I,K,ChunkSize)

d3.writeXYZ(filename,x,y,z,I,J,K)


end




