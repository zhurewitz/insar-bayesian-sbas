%% Read Series
% Read the stack/timeseries of data in a single (j,i) location

function data= readSeries(filename,path,name,j,i)

start= [j i 1];
count= [1 1 Inf];

data= squeeze(h5.read(filename,path,name,start,count));

end

