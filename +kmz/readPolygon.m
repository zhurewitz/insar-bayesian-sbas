%% KMZ.readPolygon
% Recursive reads all polygons in a KMZ file

function [long,lat]= readPolygon(filename)
S= kmz.readKMZStruct(filename);
[long,lat]= recursiveAppendPolygon(S);
end


function [long,lat]= recursiveAppendPolygon(S,long,lat)

arguments
    S
    long= [];
    lat= [];
end

names= string(fieldnames(S));

names= names(~endsWith(names,"Attribute"));

for i= 1:length(names)
    G= [S.(names(i))];
    
    if isstruct(G(1))
        % S.(names(i))
        
        if strcmp(names(i),"Polygon")
            for j= 1:length(G)
                [long,lat]= appendPolygon(G(j),long,lat);
            end
        else
            for j= 1:length(G)
                [long,lat]= recursiveAppendPolygon(G(j),long,lat);
            end
        end
    end
end

end


function [long,lat]= appendPolygon(P,long,lat)

coordstr= P.outerBoundaryIs.LinearRing.coordinates;

coords= reshape(str2num(coordstr),3,[]); %#ok<ST2NM>

if isempty(long)
    long= coords(1,1:end-1);
    lat= coords(2,1:end-1);
else
    long= [long nan coords(1,1:end-1)]; 
    lat= [lat nan coords(2,1:end-1)]; 
end

for i= 1:length(P.innerBoundaryIs)
    coordstr= P.innerBoundaryIs(i).LinearRing.coordinates;

    coords= reshape(str2num(coordstr),3,[]); %#ok<ST2NM>

    long= [long nan coords(1,1:end-1)]; %#ok<AGROW>
    lat= [lat nan coords(2,1:end-1)]; %#ok<AGROW>
end

end






