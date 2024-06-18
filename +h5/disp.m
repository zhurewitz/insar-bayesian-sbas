%% Display H5 structure

function disp(S,showAttributes,level,type)
arguments
    S
    showAttributes= false;
    level= 0;
    type= 'group';
end

if ~isa(S,'struct')
    S= h5info(S);
end

SPACES= repmat('  ',1,level);

switch type
    case 'group'
        [~,levelName]= fileparts(S.Name);
        fprintf('%s/%s\n',SPACES,levelName)
    case 'dataset'
        SIZE= S.Dataspace.Size;
        if isscalar(SIZE); SIZE= [SIZE 1]; end
        sizestr= join(string(SIZE),' x ');
        classstr= lower(S.Datatype.Class(5:end));
        fprintf('%s%s : %s %s\n',SPACES,S.Name,sizestr,classstr)
    case 'attribute'
        classstr= lower(S.Datatype.Class(5:end));
        switch classstr
            case 'string'
                outstring= sprintf('"%s"',string(S.Value));
            case 'float'
                
                SIZE= S.Dataspace.Size;
                if prod(SIZE) <= 4
                    outstring= sprintf('%0.4g ',S.Value);
                else
                    if isscalar(SIZE); SIZE= [SIZE 1]; end
                    sizestr= join(string(SIZE),' x ');
                    outstring= sprintf('%s %s',sizestr,classstr);
                end
        end
        
        fprintf('%s%s : %s\n',SPACES,S.Name,outstring)
end

if showAttributes
    if isfield(S,'Attributes')
        for i= 1:length(S.Attributes)
            h5.disp(S.Attributes(i),showAttributes,level+1,'attribute')
        end
    end
end
if isfield(S,'Datasets')
    for i= 1:length(S.Datasets)
        h5.disp(S.Datasets(i),showAttributes,level+1,'dataset')
    end
end
if isfield(S,'Groups')
    for i= 1:length(S.Groups)
        h5.disp(S.Groups(i),showAttributes,level+1,'group')
    end
end

end