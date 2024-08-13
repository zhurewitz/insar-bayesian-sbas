%% Bar Plot

function bar(x,y,c)

gap= .1*min(diff(x));

hold on
for i= 1:length(x)
    if i ~= length(x)
        rightWidth= .5*(x(i+1)-x(i));
    end
    if i ~= 1
        leftWidth= .5*(x(i)-x(i-1));
    end
    
    if i == 1
        leftWidth= rightWidth;
    end
    if i == length(x)
        rightWidth= leftWidth;
    end
    
    X= x(i)+ [-leftWidth+gap rightWidth-gap];
    
    fill(X([1 1 2 2]),[0 y(i) y(i) 0],c(i),'EdgeColor','none')
end
hold off
set(gca,'FontSize',16,'FontName','Times')
set(gcf,'Color','white')

end


