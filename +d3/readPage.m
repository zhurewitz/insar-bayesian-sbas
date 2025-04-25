%% d3.readPage

function [data,x,y,z]= readPage(filename,k)

[data,x,y,z]= d3.read(filename,[],[],k);

z= z(k);

end

