%% Compact Tiled Layout
function [tile,sgt]= tiledlayoutcompact(TITLE,m,n,NEXTTILE)

arguments
    TITLE= '';
    m= [];
    n= [];
    NEXTTILE= true;
end

if isempty(m)
    TILE= tiledlayout('flow');
elseif isempty(n)
    TILE= tiledlayout(m,m);
else
    TILE= tiledlayout(m,n);
end


TILE.TileSpacing = 'compact';
TILE.Padding= 'compact';

if NEXTTILE
    nexttile
end

SGT= sgtitle(TITLE,'FontSize',18,'FontWeight','bold','FontName','Times');


if nargout >= 1
    tile= TILE;
end

if nargout >= 2
    sgt= SGT;
end


end