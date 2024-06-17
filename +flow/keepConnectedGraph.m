%% Keep Largest Fully Connected Subgraph
% Sometimes there are interferograms which do not connect to the larger
% network. They must be removed so that the SBAS inversion is well-posed

function connectedFrames= keepConnectedGraph(frameTable)

% Unique missions and tracks
Missions= unique(frameTable.Mission);
Tracks= unique(frameTable.Track)';

connectedFrames= table;
for mission= Missions
    for track= Tracks
        I= strcmpi(frameTable.Mission,mission) & frameTable.Track == track;
        subTable= frameTable(I,:);
        
        primaryDate= subTable.PrimaryDate;
        secondaryDate= subTable.SecondaryDate;
        
        Date= unique([primaryDate secondaryDate]);

        Ndates= length(Date);
        Ninf= height(subTable);
        
        % Adjacency matrix and graph
        A= false(Ndates);
        for inf= 1:Ninf
            i= find(Date == primaryDate(inf));
            j= find(Date == secondaryDate(inf));

            A(i,j)= true;
            A(j,i)= true;
        end
        G= graph(A);
        
        % Connected components
        C= conncomp(G);
        
        % Remove nodes (dates) which are not part of the largest connected
        % subgraph (sub-interferogram network)
        IremoveDate= C ~= mode(C);
        
        if sum(IremoveDate) > 0
            DatesToRemove= Date(IremoveDate);

            IremoveInf= false(Ninf,1);
            for k= 1:Ninf
                IremoveInf(k)= any(primaryDate(k) == DatesToRemove | ...
                    secondaryDate(k) == DatesToRemove);
            end

            connectedFrames= [connectedFrames; subTable(~IremoveInf,:)]; %#ok<AGROW>
        else
            connectedFrames= [connectedFrames; subTable]; %#ok<AGROW>
        end
    end
end

end