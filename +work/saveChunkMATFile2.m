%% Save Chunk

function Data= saveChunkMATFile2(filename,varname,chunkdata,j,i,ChunkSize,Size)

arguments
    filename
    varname
    chunkdata
    j
    i
    ChunkSize
    Size
end

% Load variable if possible
try
    warning off
    S= load(filename,varname);
    warning on
    fulldata= S.(varname);
catch
    fulldata= nan([Size(1:2) size(chunkdata,3)]);
end

% Place this data into the existing data at the i-th location
[J,I]= d3.chunkIndices(ChunkSize,j,i);
J= J(1:size(chunkdata,1));
I= I(1:size(chunkdata,2));

fulldata(J,I,:)= chunkdata;

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