%% d3.readStartCountStride1D
% Convert from indices to start/count/stride notation

function [start, count, stride]= readStartCountStride1D(I)

arguments
    I= [];
end

if isempty(I)
    start= 1;
    count= Inf;
    stride= 1;
else
    start= I(1);
    count= length(I);
    
    if isscalar(I)
        stride= 1;
    else
        stride= diff(I(1:2));
    end
end

end