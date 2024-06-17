%% Phase Mis-Closure Mask Calculation

function processClosureMask(L1filename,L2filename,varargin)

arguments
    L1filename
    L2filename= [];
end

arguments (Repeating)
    varargin
end


if isempty(L2filename)
    L2filename= L1filename;
end


[MaxTriplets,found]= utils.parseIn(varargin,'MaxTriplets');
if ~found
    MaxTriplets= Inf;
end

[Missions,Tracks]= io.readMissionTracks(L1filename,'L1');

t2= toc2;
for m= 1:length(Missions)
    Mission= Missions(m);
    for t= 1:length(Tracks)
        Track= Tracks(t);
        
        path= '/interferogram/L1-stitched';
        name= strcat(Mission,'-',string(Track));
        if ~h5.exist(L1filename,path,name)
            continue
        end
        
        
        [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
        
        % Interferogram graph/network
        [PostingDate,GRAPH]= utils.datePairsToGraph(PrimaryDate,SecondaryDate);
        
        % Calculate all small cycles within the interferogram network
        Cycles = allcycles(GRAPH,'MaxCycleLength',3);

        Ntriplets= length(Cycles);
        for i= 1:min(Ntriplets,MaxTriplets)
            Cycle= Cycles{i};
            
            I12= PrimaryDate == PostingDate(Cycle(1)) & SecondaryDate == PostingDate(Cycle(2));
            I23= PrimaryDate == PostingDate(Cycle(2)) & SecondaryDate == PostingDate(Cycle(3));
            I13= PrimaryDate == PostingDate(Cycle(1)) & SecondaryDate == PostingDate(Cycle(3));
            
            % Positions in 3rd dimension of stack of the three
            % interferograms comprising the cycle
            k= [find(I12,1);find(I23,1);find(I13,1)];

            if length(k) < 3
                fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d could not be constructed.\n',...
                    m,length(Missions),t,length(Tracks),i,Ntriplets)
                continue
            end
            
            try
                Stack= io.loadL1Stack(...
                    L1filename,Mission,Track,PrimaryDate(k),SecondaryDate(k));
            catch
                fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d interferograms could not be loaded.\n',...
                    m,length(Missions),t,length(Tracks),i,Ntriplets)
                continue
            end

            % Phase closure
            Cu= Stack(:,:,1)+ Stack(:,:,2)- Stack(:,:,3);
            
            % Pixels of strong phase misclosure
            MISCLOSED= quicksmooth(abs(Cu- quicksmooth(Cu,50)),5)> 5;
            
            % Load current mask (if exists) and save new mask, for all
            % interferograms in the cycle
            for j= 1:3
                closureMask= io.loadClosureMask(L2filename,Mission,Track,PrimaryDate(k(j)),SecondaryDate(k(j)));
                
                if isempty(closureMask)
                    closureMask= MISCLOSED;
                else
                    % Union of new mask with current mask
                    closureMask= closureMask | MISCLOSED;
                end
                
                saveClosureMask(L2filename,Mission,Track,PrimaryDate(k(j)),SecondaryDate(k(j)),closureMask,k(j))
            end
            
            fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d processed. Elapsed time %0.1fmin.\n',...
                m,length(Missions),t,length(Tracks),i,Ntriplets,(toc-t2)/60)
        end

    end
end

end







%% Smooth

function Y= quicksmooth(X,window)
arguments
    X
    window= 2;
end

Y= movmean(movmean(X,window,1,'omitmissing'),window,2,'omitmissing');
end




%% Save

function saveClosureMask(L2filename,Mission,Track,PrimaryDate,SecondaryDate,closureMask,k)

basepath= '/interferogram/L2-closureCorrected';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr,'closureMask');

h5.write2DInf(L2filename,path,'mask',closureMask,k);
h5.writeatts(L2filename,path,'mask','description','Closure phase mask')

h5.writeScalar(L2filename,path,'primaryDate',PrimaryDate,Inf,k)
h5.writeScalar(L2filename,path,'secondaryDate',SecondaryDate,Inf,k)

end
