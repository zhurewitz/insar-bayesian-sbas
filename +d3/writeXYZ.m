%% d3.writeXYZ

function writeXYZ(filename,x,y,z,I,J,K)

arguments
    filename
    x= [];
    y= [];
    z= [];
    I= [];
    J= [];
    K= [];
end

if ~isempty(x)
    d3.write1D(filename,"x",x,I)
end

if ~isempty(y)
    d3.write1D(filename,"y",y,J)
end

if ~isempty(z)
    d3.write1D(filename,"z",z,K)
end

end

