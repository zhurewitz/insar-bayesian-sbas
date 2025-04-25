%% Save Chunk

function Data= saveVariableMATFile(filename,varname,data,i)

arguments
    filename
    varname
    data
    i= [];
end

% Load variable if possible
try
    warning off
    S= load(filename,varname);
    warning on
    fulldata= S.(varname);
catch
    fulldata= data;
    fulldata(:)= [];
end

% Place this data into the existing data at the i-th location
if isempty(i)
    fulldata= data;
else
    fulldata(i,:)= data;
end

% Resave data
if exist(filename,'file')
    save(filename,"-fromstruct",struct(varname,fulldata),"-append")
else
    save(filename,"-fromstruct",struct(varname,fulldata))
end

if nargout > 0
    Data= fulldata;
end

end