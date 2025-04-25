%% d3.Read

function [data,x,y,z]= read(filename,J,I,K)

arguments
    filename
    J= [];
    I= [];
    K= [];
end

if ~h5.exist(filename)
    error("File not found")
end

if isempty(J) && isempty(I) && isempty(K)
    data= h5.read(filename,"/","data");
    
else
    [start, count, stride]= d3.readStartCountStride3D(J,I,K);

    data= h5.read(filename,"/","data",start,count,stride);
end


if nargout >= 2
    x= h5.read(filename,"/","x");
end

if nargout >= 3
    y= h5.read(filename,"/","y");
end

if nargout >= 4
    z= h5.read(filename,"/","z");
end


end