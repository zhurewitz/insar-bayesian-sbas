%% d3.startCountStride
% Convert from indices to start/count/stride notation

function [start, count, stride]= writeStartCountStride3D(data,J,I,K)

arguments
    data
    J= [];
    I= [];
    K= [];
end

if isempty(data) && isempty(J) && isempty(I) && isempty(K)
    error("If data is empty, I,J,and K must be non-empty")
end

if isempty(J)
    J= 1:size(data,1);
end
if isempty(I)
    I= 1:size(data,2);
end
if isempty(K)
    K= 1:size(data,3);
end

J= J(1:size(data,1));
I= I(1:size(data,2));
K= K(1:size(data,3));


start= [0 0 0];
count= [0 0 0];
stride= [0 0 0];

[start1,count1,stride1]= d3.writeStartCountStride1D([],J);
start(1)= start1;
count(1)= count1;
stride(1)= stride1;

[start1,count1,stride1]= d3.writeStartCountStride1D([],I);
start(2)= start1;
count(2)= count1;
stride(2)= stride1;

[start1,count1,stride1]= d3.writeStartCountStride1D([],K);
start(3)= start1;
count(3)= count1;
stride(3)= stride1;


end