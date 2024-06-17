%% Keep Table Variables
% And delete the rest

function T= keepTableVariables(T,varNames)

[~,ia]= intersect(T.Properties.VariableNames,varNames,'stable');

if any(ia)
    T= T(:,ia);
end

end

