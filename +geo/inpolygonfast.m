%% INPOLYGON FAST
% Copyright (C) 2024 Zel Hurewitz
% SPDX-License-Identifier: GPL-3.0-or-later
% 
% Quickly checks if a set of points given by X,Y are inside a single
% polygon (not necessarily contiguous) defined by the vertices VX,VY
% Input:
%   X - (N x 1) x-positions of query points
%   Y - (N x 1) y-positions of query points
%   VX- (Nv x 1) x-positions of vertices
%   VY- (Nv x 1) y-positions of vertices
% Output:
%   IN- (N x 1 logical) IN(i) is true if that the point (X(i),Y(i)) is
%   inside the polygon

function IN= inpolygonfast(X,Y,VX,VY)

IN= false(size(X));

% Iterate over contiguous sub-polygons

[Istart, Iend, Value]= uniqueRegions(~isnan(VX) & ~isnan(VY));

for i= 1:length(Istart)
    if Value(i)
        I= Istart(i):Iend(i);

        % IN= IN | inpolygonfastContiguous(X,Y,VX(I),VY(I));
        IN= xor(IN,inpolygonfastContiguous(X,Y,VX(I),VY(I)));
    end
end

end





%% INPOLYGONFAST, for a Contiguous Polygon

function IN= inpolygonfastContiguous(X,Y,VX,VY)

Nv= length(VX);

OriginalLinearID= 1:length(X);

if ~issorted(Y)
    [Y,Isort]= sort(Y);
    X= X(Isort);
    OriginalLinearID= OriginalLinearID(Isort);
end

[Yunique,~,Ic]= unique(Y);
[Istart, Iend, YID]= uniqueRegions(Ic);


ABOVE= VY > Yunique'; % Boolean of each vertex above or below each unique y-position
CROSS= xor(ABOVE, circshift(ABOVE,-1,1)); % Positions of crosses
CROSS= sparse(CROSS); 


% Find all line segments which cross 
% J is the index within the line V
% I is the index within Yunique
[J,Icross]= ind2sub(size(CROSS),find(CROSS));


modn= @(x,n) mod(x-1,n)+ 1;

x1= VX(J); % First point of crossing line segment, x-value
y1= VY(J); %y-value
x2= VX(modn(J+1,Nv)); % Second point of crossing line segment, x-value
y2= VY(modn(J+1,Nv)); % y-value
yq= Yunique(Icross); % y-value of line crossed by the line segment

Xcross= x1+ (x2-x1).*(yq-y1)./(y2-y1); % x-value at crossing point
% Ycross= yq; % y- value of same

IN= nan(size(X));

% If number of crossings is even, outside polygon. If odd, inside
for i= 1:length(Istart)
    IN(OriginalLinearID(Istart(i):Iend(i)))=  ...
        mod(sum(X(Istart(i):Iend(i)) > Xcross(Icross == YID(i))',2),2);
end

end





%% Unique Regions
% Splits an array into regions from Istart(i):Iend(i), where the array
% value in that section is Value(i)
% 
% Empty arrays, logical arrays, and arrays with a single value all work
% fine
%
% Numerical Example: uniqueRegions([1 3 3 3 2 2 3 3])
% Output: Istart= [1 2 5 7]; Iend= [1 4 6 8]; Value= [1 3 2 3];
%
% Logical Example: uniqueRegions([0 0 0 1 1 0 1 1 1 1])
% Output: Istart= [1 4 6 7]; Iend= [3 5 6 10]; Value= [0 1 0 1];

function [Istart, Iend, Value]= uniqueRegions(A)

arguments
    A (1,:) 
end

F= find(diff(A));

Istart= [1 max(F+1,1)];
Iend= [min(F,length(A)) length(A)];

Igood= Iend >= Istart;
Istart= Istart(Igood);
Iend= Iend(Igood);

Value= A(Istart);

end






