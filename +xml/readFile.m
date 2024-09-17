%% Read File

function S= readFile(filename)

arguments
    filename {mustBeFile}
end

S= readstruct(filename);

% Replace idAttribute with ID
if isfield(S.Station,"idAttribute")
    ID= [S.Station.idAttribute];
    
    for i= 1:length(S.Station)
        S.Station(i).ID= ID(i);
    end
    S.Station= rmfield(S.Station,"idAttribute");
end

end