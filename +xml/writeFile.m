%% Write File

function writeFile(filename,S)

arguments
    filename (1,1) string
    S
end

% Replace ID with idAttribute
if isfield(S.Station,"ID")
    for i= 1:length(S.Station)
        S.Station(i).idAttribute= S.Station(i).ID;
    end
    S.Station= rmfield(S.Station,"ID");
end

writestruct(S,filename)

end

