%% H5.READCHUNKSTACK

function ChunkStack= readChunkStack(filename,path,name,j,i)

arguments
    filename
    path
    name
    j= 1;
    i= 1;
end

datasetname= fullfile(path,name);

S= h5info(filename,datasetname);
ChunkSize= S.ChunkSize;

Size= S.Dataspace.Size;

start= ([j i 1]-1).*ChunkSize+ 1;
count= [ChunkSize(1:2) Inf];

count(1)= min(ChunkSize(1),Size(1)- start(1)+ 1);
count(2)= min(ChunkSize(2),Size(2)- start(2)+ 1);

ChunkStack= h5.read(filename,path,name,start,count);

end