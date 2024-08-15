%% INPOLYGON FAST for a Grid
% Copyright (C) 2024 Zel Hurewitz
% SPDX-License-Identifier: GPL-3.0-or-later
% 
% Quickly checks if a grid of points defined by GX,GY are inside a single
% polygon (not necessarily contiguous) defined by the vertices VX,VY
% Input:
%   GX - (Nx x 1) x-positions of grid
%   GY - (Ny x 1) y-positions of grid
%   VX- (Nv x 1) x-positions of vertices
%   VY- (Nv x 1) y-positions of vertices
% Output:
%   IN- (Ny x Nx logical) IN(j,i) is true if that the point (GX(i),GY(j))
%   is inside the polygon

function IN= inpolygonfastGrid(GX,GY,VX,VY)

arguments
    GX (:,1)
    GY (:,1)
    VX (:,1)
    VY (:,1)
end

[X,Y]= meshgrid(GX,GY);

X= X';
Y= Y';

SIZE= size(X);

x= X(:);
y= Y(:);

IN= geo.inpolygonfast(x,y,VX,VY);

IN= reshape(IN,SIZE)';

end



