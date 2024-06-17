%% H5 - Read Attributes

function Attributes= readatts(h5filename,path,name)

arguments
    h5filename
    path= '';
    name= '';
end

Info= h5info(h5filename,fullfile(path,name));

Name= {Info.Attributes.Name};
Value= {Info.Attributes.Value};

for i= 1:length(Value)
    if iscellstr(Value{i}) || ischar(Value{i})
        Value{i}= string(Value{i});
    end
end

Attributes= [Name; Value];
Attributes= Attributes(:)';

end