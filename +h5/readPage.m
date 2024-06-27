%% Read Page

function data= readPage(filename,path,name,k)

arguments
    filename
    path
    name
    k= 1;
end

S= h5info(L1filename,fullfile(path,name));

Size= S.Dataspace.Size;

if numel(Size) == 2
    start= [1 1];
    count= Size;
else
    start= [1 1 k];
    count= [Size(1:2) 1];
end

data= h5.read(filename,path,name,start,count);

end



