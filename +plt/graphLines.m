%% Graph Lines

function [lx,ly] = graphLines(G, x, y)

E= G.Edges.EndNodes;

if isdatetime(x)
    lx= reshape([x(E'); NaT(1,height(E))],1,[]);
else
    lx= reshape([x(E'); nan(1,height(E))],1,[]);
end

ly= reshape([y(E'); nan(1,height(E))],1,[]);

end

