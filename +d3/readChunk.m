%% d3.readChunk

function [data,x,y,z]= readChunk(filename,j,i,k)

[~,ChunkSize,Size]= h5.chunkCount(filename,"/","data");

[J,I,K]= d3.chunkIndices(ChunkSize,Size,j,i,k);

[data,x,y,z]= d3.read(filename,J,I,K);

x= x(I);
y= y(J);
z= z(K);

end

