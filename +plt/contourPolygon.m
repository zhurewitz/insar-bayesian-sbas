%% Contour

function [px,py]= contourPolygon(x,y,z,level)

M= contourc(x,y,z,[level level]);

N= size(M,2);
i= 1;
while i < N
    n= M(2,i);

    M(:,i)= nan;

    i= i+ n+ 1;
end

M(:,1)= [];

px= M(1,:)';
py= M(2,:)';

end

