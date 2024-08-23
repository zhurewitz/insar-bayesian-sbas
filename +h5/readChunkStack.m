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

start= ([j i 1]-1).*ChunkSize+ 1;
count= [ChunkSize(1:2) Inf];

ChunkStack= h5.read(filename,path,name,start,count);

end