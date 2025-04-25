%% IO.HYP3.READMETADATA

function metaData= readMetaData(dirname,dataName)

[dir,name]= fileparts(dirname);
filename= fullfile(dir,name,strcat(name,'.txt'));

try
    S= readlines(filename);
catch
    warning('Track could not be read from file %s',filename)
    metaData= [];
    return
end

I= contains(S,dataName);
metaData= extractAfter(S(I),strcat(dataName,": "));


end

