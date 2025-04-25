%% d3.readSeries

function [data,x,y,z]= readSeries(filename,j,i)

[data,x,y,z]= d3.read(filename,j,i);

data= squeeze(data);

x= x(i);
y= y(j);

end