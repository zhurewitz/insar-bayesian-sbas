%% Author to Attribution
% Permissively returns attribution struct given author or input attribution
% struct

function Attribution= authorToAttribution(A)

if isstruct(A)
    Attribution= A;
else
    Attribution= xml.generateAttribution(A);
end

end

