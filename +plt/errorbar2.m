%% Errorbar2
% A better errorbar function
%
% Inputs:
%   x - (N x 1) x-position of points
%   y - (N x 1) y-position of points
%   ud - (N x 1) uncertainty in the down direction
%   uu - (N x 1) uncertainty in the up direction (If empty, uu = ud)
%   LineWidth - width of error lines, default 2
%   Color - (1 x 3) RGB color (limit [0 1])
%   LineAlpha - transparency value of error lines, default 1 (fully opaque)
%   MarkerSize - size of markers in scatter function (see scatter
%       documentation for details). Default 100. If 0, scatter is not plotted
%   MarkerAlpha - transparency value of markers

function errorbar2(x,y,ud,uu,LineWidth,Color,LineAlpha,MarkerSize,MarkerAlpha)

arguments
    x (:,1)
    y (:,1)
    ud (:,1)
    uu (:,1)= [];
    LineWidth= 2;
    Color= [];
    LineAlpha= 1;
    MarkerSize= 100;
    MarkerAlpha= [];
end

if isempty(uu)
    uu= ud;
end

if isempty(LineWidth)
    LineWidth= 2;
end

if isempty(Color)
    Color= lines(1);
end

if isempty(LineAlpha)
    LineAlpha= 1;
end

if isempty(MarkerSize)
    MarkerSize= 100;
end

if isempty(MarkerAlpha)
    MarkerAlpha= LineAlpha;
end



if length(Color) < 4
    Color= [Color LineAlpha];
end



N= length(x);


x2= [x x repmat(missing,N,1)]';
y2= [y-ud y+uu repmat(missing,N,1)]';

plot(x2(:),y2(:),"LineWidth",LineWidth,'Color',Color)
if MarkerSize > 0
    hold on
    scatter(x,y,MarkerSize,Color(:,1:3),'filled',MarkerFaceAlpha=MarkerAlpha)
end
plt.pltOptions


end


