%% d3.size

function Size= size(filename,dim)

arguments
    filename
    dim= [];
end

S= h5info(filename,"/data");
Size= S.Dataspace.Size;

if ~isempty(dim)
    Size= Size(dim);
end


