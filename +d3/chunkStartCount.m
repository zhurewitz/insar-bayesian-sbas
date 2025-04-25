%% D3.CHUNKSTARTCOUNT

function [start,count]= chunkStartCount(...
    ChunkSize,j,i,k,Size)

arguments
    ChunkSize
    j= 1;
    i= 1;
    k= 1;
    Size= [];
end

start= ([j i k]-1).*ChunkSize+ 1;

if isempty(Size)
    count= ChunkSize;
else
    count= min(Size,start+ ChunkSize- 1)- start+ 1;
end

end
