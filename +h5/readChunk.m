%% HDF5 Read Chunk 

function Chunk= readChunk(filename,path,name,j,i,k)

arguments
    filename
    path
    name
    j= 1;
    i= 1;
    k= 1;
end

datasetname= fullfile(path,name);

S= h5info(filename,datasetname);
ChunkSize= S.ChunkSize;

start= ([j i k]-1).*ChunkSize+ 1;
count= ChunkSize;

Chunk= h5.read(filename,path,name,start,count);

end