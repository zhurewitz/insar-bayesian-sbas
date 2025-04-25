%% d3.writePage

function writePage(filename,data,K,x,y,z,ChunkSize)

arguments
    filename
    data
    K
    x= [];
    y= [];
    z= [];
    ChunkSize= [200 200 1];
end

d3.write(filename,data,[],[],K,ChunkSize)

d3.writeXYZ(filename,x,y,z,[],[],K)

end
