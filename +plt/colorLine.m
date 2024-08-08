%% COLORLINE(x,y,c,LineWidth)
% A function to draw a colorful line
% 
% Inputs:
%   x - vector (length N) of x-position
%   y - vector (length N) of y-position
%   c - Color (optional)
%       1. No input or empty: color by y
%       2. Vector of length N: color according to colormap
%       3. RBG vector: color a single value
%       4. RBG matrix (N x 3): color according to RBG values
%   LineWidth (optional)
% Output:
%   h - surface graphics object
% 
% Help: COLORLINE() or COLORLINE("help") show the help
% Unit Test: COLORLINE("test") performs a unit test displaying the
% function's behaviour

function h= colorLine(x,y,c,LineWidth)

arguments
    x= [];
    y (:,1)= [];
    c= [];
    LineWidth= 5;
end

warning off
if (isempty(x) && isempty(y)) || isequal(x,"help")
    help colorLine
    return
end

if isequal(x,"test")
    unitTestColorLine
    return
end
warning on

N= length(x);
x= reshape(x,N,1);

if isempty(c)
    c= y;
end

if isvector(c)
    if length(c) == N
        c= reshape(c,N,1);
    elseif length(c) == 3
        c= reshape(c,1,1,3);
        c= repmat(c,N,1,1);
    else
        error('c must be a vector of length N or 3 or an N x 3 matrix')
    end
else
    if all(size(c) == [N 3])
        c= reshape(c,N,1,3);
    else
        error('c must be a vector of length N or 3 or an N x 3 matrix')
    end
end

if isdatetime(x)
    x= [x x; NaT NaT];
else
    x= [x x; nan nan];
end

y= [y y; nan nan];
c= [c c; nan(1,2,size(c,3))];

set(gcf,'Color','white')
H= surface(x,y,zeros(size(y)),c,...
    'EdgeColor','interp','FaceColor','none','LineWidth',LineWidth);
view(0,90)
set(gca,'FontSize',16,'FontName','Times')

if nargout > 0
    h= H;
end

end




%% Unit Test
% Access with colorLine("test")

function unitTestColorLine
x= 0:.1:10;
y= sin(x);

tiledlayout('flow')
nexttile

% Case 1: No color input
colorLine(x,y)

% Case 2: Color same size as input
c= cos(2*x);
nexttile
colorLine(x,y,c)

% Case 3: Single color
c= [1 .2 .5];
nexttile
colorLine(x,y,c)

% Case 4: RGB color matrix
c= .5*[cos(2*x); sin(x+1); sin(x)]'+.5;
nexttile
colorLine(x,y,c,10)
end