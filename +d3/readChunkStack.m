%% d3.readChunkStack

function [data,x,y,z]= readChunkStack(filename,j,i)

[~,ChunkSize,Size]= d3.chunkInfo(filename);

[J,I]= d3.chunkIndices(ChunkSize,j,i,1,Size);

[data,x,y,z]= d3.read(filename,J,I,[]);

x= x(I);
y= y(J);

end

