%% H5.CHUNKSIZE

function [ChunkSize,Size]= chunkSize(filename,path,name)

arguments
    filename
    path
    name
end

S= h5info(filename,fullfile(path,name));

ChunkSize= S.ChunkSize;

Size= S.Dataspace.Size;

end