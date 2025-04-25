%% d3.startCountStride
% Convert from indices to start/count/stride notation

function [start, count, stride]= readStartCountStride3D(J,I,K)

arguments
    J= [];
    I= [];
    K= [];
end

start= [0 0 0];
count= [0 0 0];
stride= [0 0 0];

[start1,count1,stride1]= d3.readStartCountStride1D(J);
start(1)= start1;
count(1)= count1;
stride(1)= stride1;

[start1,count1,stride1]= d3.readStartCountStride1D(I);
start(2)= start1;
count(2)= count1;
stride(2)= stride1;

[start1,count1,stride1]= d3.readStartCountStride1D(K);
start(3)= start1;
count(3)= count1;
stride(3)= stride1;


end