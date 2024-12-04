%% Quiver Function

function quiver2(x,y,u,v,lengthScale,headSize)

arguments
    x
    y
    u
    v
    lengthScale= 1;
    headSize= 2;
end

h= quiver(x,y,u,v);
XLIM= xlim;
YLIM= ylim;
delete(h)

hold on
for i= 1:length(x)
    drawArrow(x(i),y(i),u(i)*lengthScale,v(i)*lengthScale,headSize,XLIM,YLIM)
end

end





%% Draw Arrow Function
function drawArrow(x,y,dx,dy, headScale,XLIM,YLIM)

arguments
    x
    y
    dx
    dy
    headScale= [];
    XLIM= []
    YLIM= [];
end

if isempty(headScale)
    headScale= 1;
end

if isempty(XLIM)
    XLIM= xlim;
end

if isempty(YLIM)
    YLIM= ylim;
end



x2= x+ dx;
y2= y+ dy;

% Direction in pixel space
[i,j]= data2pix([x x2],[y y2],XLIM,YLIM);
di= diff(i);
dj= diff(j);

% Unit vectors
u= [di dj];
u= u/norm(u);
v= [-u(2) u(1)];

% Arrow Parameters
l= 1.5;
w= 1;
k= .3;

% Arrowhead vertices in object space
xa= [0 -l -l+k -l]';
ya= [0 w/2 0 -w/2]';
X= [xa ya ones(4,1)]';


headScale= headScale*10;

% Transformation matrix
T= [headScale*u' headScale*v' [i(2); j(2)]; 0 0 1];

% Arrowhead vertices in pixel space
IJ= T*X;

% Arrowhead vertices in data space
[xa2,ya2]= pix2data(IJ(1,:),IJ(2,:),XLIM,YLIM);


%%  Plot arrow

plot([x xa2(3)],[y ya2(3)],'k',"LineWidth",2); % Plot arrow
fill(xa2,ya2,'k') % Plot arrowhead
plt.pltOptions
xlim(XLIM)
ylim(YLIM)



end




%% Coordinate Transformations

function [u,v]= data2norm(x,y,XLIM,YLIM)
u= (x- XLIM(1))/diff(XLIM);
v= (y- YLIM(1))/diff(YLIM);
end
function [x,y]= norm2data(u,v,XLIM,YLIM)
x= u*diff(XLIM)+ XLIM(1);
y= v*diff(YLIM)+ YLIM(1);
end
function [i,j]= norm2pix(u,v)
pos1= gca().InnerPosition;
x1= pos1(1)+ u*pos1(3);
y1= pos1(2)+ v*pos1(4);
pos2= gcf().Position;
i= pos2(1)+ x1*pos2(3);
j= pos2(2)+ y1*pos2(4);
end
function [u,v]= pix2norm(i,j)
pos2= gcf().Position;
x1= (i- pos2(1))/pos2(3);
y1= (j- pos2(2))/pos2(4);
pos1= gca().InnerPosition;
u= (x1-pos1(1))/pos1(3);
v= (y1-pos1(2))/pos1(4);
end

function [i,j]= data2pix(x,y,XLIM,YLIM)
[u,v]= data2norm(x,y,XLIM,YLIM);
[i,j]= norm2pix(u,v);
end

function [x,y]= pix2data(i,j,XLIM,YLIM)
[u,v]= pix2norm(i,j);
[x,y]= norm2data(u,v,XLIM,YLIM);
end