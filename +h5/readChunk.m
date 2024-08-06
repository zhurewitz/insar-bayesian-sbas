%% HDF5 Read Chunk 

function Chunk= readChunk(filename,path,name,i,j,k)

arguments
    filename
    path
    name
    i= 1;
    j= 1;
    k= 1;
end

datasetname= fullfile(path,name);

S= h5info(filename,datasetname);
ChunkSize= S.ChunkSize;

start= ([j i k]-1).*ChunkSize+ 1;
count= ChunkSize;

Chunk= h5.read(filename,path,name,start,count);

end