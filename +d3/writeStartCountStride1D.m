%% d3.startCountStride1D
% Convert from indices to start/count/stride notation

function [start, count, stride]= writeStartCountStride1D(data,I)

arguments
    data
    I= [];
end

if isempty(data) && isempty(I)
    error("If data is empty, I must not be empty")
end

if isempty(I)
    I= 1:length(data);
end

start= I(1);
count= length(I);
if isscalar(I)
    stride= 1;
else
    stride= diff(I(1:2));
end

end