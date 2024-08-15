%% Line Intersect Fast
% Copyright (C) 2024 Zel Hurewitz
% SPDX-License-Identifier: GPL-3.0-or-later
% 
% Based off: https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection

function INTERSECT= lineintersectfast(vx1,vy1,vx2,vy2)

arguments
    vx1 (1,:)
    vy1 (1,:)
    vx2 (1,:)= [];
    vy2 (1,:)= [];
end

if isempty(vx2); vx2= vx1; end
if isempty(vy2); vy2= vy1; end


x1= vx1(1:end-1);
x2= vx1(2:end);
x3= vx2(1:end-1)';
x4= vx2(2:end)';
y1= vy1(1:end-1);
y2= vy1(2:end);
y3= vy2(1:end-1)';
y4= vy2(2:end)';

% Determinants
D1= (x1- x3).*(y3- y4)- (y1- y3).*(x3- x4);
D2= -(x1- x2).*(y1- y3)+ (y1- y2).*(x1- x3);
D= (x1- x2).*(y3- y4)- (y1- y2).*(x3- x4);

% Multiply everything by D to handle signs correctly
INTERSECT= D1.*D >= 0 & D1.*D <= D.*D & D2.*D >= 0 & D2.*D <= D.*D;

end








