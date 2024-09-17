%% Generate Attribution

function Attribution= generateAttribution(Author,Key,Value)

arguments
    Author (1,1) string
end

arguments (Repeating)
    Key
    Value
end

Attribution= struct;
Attribution.Author= Author;

for i= 1:length(Key)
    Attribution.(Key{i})= Value{i};
end
Attribution.AttributionDate= datetime("today");

end

