%% EXIST
% h5.EXIST - displays help 
% A= h5.EXIST(filename) - returns true if file exists
% A= h5.EXIST(filename,path) - returns true if path exists in h5 file (error
% if file does not exist)
% A= h5.EXIST(filename,path,name) - returns true if group or dataset path/name
% exists in h5 file (error if file does not exist)
% A= h5.EXIST(filename,path,name,attname) - returns true if attribute
% exists
% [A,Info]= h5.EXIST(...) - Additionally returns h5info struct

function [A,Info]= exist(filename,path,name,attname)

arguments
    filename= [];
    path= [];
    name= [];
    attname= [];
end

if isempty(filename)
    help h5.exist
    A= false;
    if nargout > 1; Info= []; end
    return
end


if isempty(path) & isempty(name)
    A= exist(filename,'file');
    if nargout > 1; Info= h5info(filename); end
    return
end

if ~exist(filename,'file')
    error('File does not exist')
end

if isempty(attname)
    try
        INFO= h5info(filename,fullfile(path,name));

        A= true;
        if nargout > 1; Info= INFO; end
    catch
        A= false;
        if nargout > 1; Info= []; end
    end
else
    try
        INFO= h5info(filename,fullfile(path,name));
        
        ATTNAMES= string({INFO.Attributes.Name});
        I= strcmp(ATTNAMES,attname);
        
        A= any(I);
        if nargout > 1 && A; Info= INFO.Attributes(I); end
    catch
        A= false;
        if nargout > 1; Info= []; end
    end
end

end


