%% H5.PAGESIZE

function Size= pageSize(filename,path,name)

arguments
    filename
    path
    name
end

S= h5info(filename,fullfile(path,name));

Size= S.Dataspace.Size(1:2);

end

