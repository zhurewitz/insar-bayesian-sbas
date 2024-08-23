%% H5.CHUNKCOUNT

function Chunks= chunkCount(filename,path,name)

arguments
    filename
    path
    name
end

datasetname= fullfile(path,name);

S= h5info(filename,datasetname);
ChunkSize= S.ChunkSize;

Size= S.Dataspace.Size;

Chunks= ceil(Size./ChunkSize);

end