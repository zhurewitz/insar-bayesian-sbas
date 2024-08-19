%% KMZ.COORDINATES
% Format x,y coordinates as a string for KMZ

function coordstr= coordinates(x,y)

arguments
    x (1,:)
    y (1,:)
end

coords= [x; y; zeros(1,length(x))];

% Format coordinate string
coordstr= sprintf("%g,%g,%g ",coords);

end

