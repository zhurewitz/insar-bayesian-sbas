%% Apply Closure Mask Correction
% Loads interferogram and mask, runs flow.correctInterferogram2 to correct
% the interferogram, and saves the corrected interferogram as a L2 product

function applyClosureCorrection(L1filename,L2filename)

arguments
    L1filename
    L2filename= [];
end

if isempty(L2filename)
    L2filename= L1filename;
end


[Missions,Tracks]= io.readMissionTracks(L1filename,'L1');

t2= utils.tictoc;
for m= 1:length(Missions)
    Mission= Missions(m);
    for t= 1:length(Tracks)
        Track= Tracks(t);
        
        path= '/interferogram/L1-stitched';
        name= strcat(Mission,'-',string(Track));
        if ~h5.exist(L1filename,path,name)
            continue
        end
        
        Mission= Missions(m);
        Track= Tracks(t);
        
        [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
        
        Ninf= length(PrimaryDate);
        
        for k= 1:length(PrimaryDate)
            Interferogram= io.loadL1Stack(L1filename,Mission,Track,PrimaryDate(k),SecondaryDate(k),[],[]);
            ClosureMask= io.loadClosureMask(L2filename,Mission,Track,PrimaryDate(k),SecondaryDate(k));

            CorrectedInterferogram= flow.correctInterferogram(...
                Interferogram,ClosureMask);

            saveCorrectedInterferogram(L2filename,Mission,Track,PrimaryDate(k),SecondaryDate(k),CorrectedInterferogram,k)
        
            if k > 1
                copyAttributes(L1filename,L2filename,Mission,Track)
            end
            
            fprintf('Mission %d/%d. Track %d/%d. Interferogram %d/%d processed. Elapsed time %0.1fmin.\n',...
                m,length(Missions),t,length(Tracks),k,Ninf,(toc-t2)/60)
        end
        
        
    end
end


end







function saveCorrectedInterferogram(L2filename,Mission,Track,PrimaryDate,...
    SecondaryDate,CorrectedInterferogram,k)

basepath= '/interferogram/L2-closureCorrected';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

h5.write2DInf(L2filename,path,'data',CorrectedInterferogram,k);

h5.writeScalar(L2filename,path,'primaryDate',PrimaryDate,Inf,k)
h5.writeScalar(L2filename,path,'secondaryDate',SecondaryDate,Inf,k)

end





function copyAttributes(L1filename,L2filename,Mission,Track)

if isempty(L2filename)
    L2filename= L1filename;
end

trackstr= strcat(Mission,'-',string(Track));

L1basepath= '/interferogram/L1-stitched';
L2basepath= '/interferogram/L2-closureCorrected';

L1path= fullfile(L1basepath,trackstr);
L2path= fullfile(L2basepath,trackstr);

Attributes= h5.readatts(L1filename,L1path);
h5.writeatts(L2filename,L2path,'',Attributes{:})

Attributes= h5.readatts(L1filename,L1path,'data');
h5.writeatts(L2filename,L2path,'data',Attributes{:})

end