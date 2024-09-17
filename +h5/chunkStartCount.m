%% H5.CHUNKSTARTCOUNT

function [start,count]= chunkStartCount(...
    ChunkSize,Size,j,i)

arguments
    ChunkSize
    Size
    j
    i
end

start= ([j i 1]-1).*ChunkSize+ 1;
count= [ChunkSize(1:2) Inf];

count(1)= min(ChunkSize(1),Size(1)- start(1)+ 1);
count(2)= min(ChunkSize(2),Size(2)- start(2)+ 1);

end

