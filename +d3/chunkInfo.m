%% d3.chunkInfo

function [Chunks,ChunkSize,Size]= chunkInfo(filename)

arguments
    filename
end

S= h5info(filename,"/data");

ChunkSize= S.ChunkSize;

Size= S.Dataspace.Size;

Chunks= ceil(Size./ChunkSize);

end