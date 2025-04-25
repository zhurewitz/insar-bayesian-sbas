%% Write Chunk Stack
% Writes a stack of chunks to a dataset with infinite size in the 3rd
% dimension to an HDF5 file, creating the dataset if necessary

function writeChunkStack(filename,data,j,i,x,y,z,ChunkSize)

arguments
    filename
    data
    j
    i
    x= [];
    y= [];
    z= [];
    ChunkSize= [200 200 2];
end

[J,I]= d3.chunkIndices(ChunkSize,j,i);

d3.write(filename,data,J,I,[],ChunkSize)

if length(x) > ChunkSize(2)
    I= [];
end
if length(y) > ChunkSize(1)
    J= [];
end

d3.writeXYZ(filename,x,y,z,I,J,[])

end




