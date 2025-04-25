%% d3.readXYZ

function [x,y,z]= readXYZ(filename)

x= h5.read(filename,"/","x");
y= h5.read(filename,"/","y");
z= h5.read(filename,"/","z");

end


