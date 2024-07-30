%% Record Phase Closure

function recordClosure(L1filename,L2filename,varargin)

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
        
        
        [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
        grid= h5.readGrid(L1filename,'/grid');
        
        % Interferogram graph/network
        [PostingDate,GRAPH]= utils.datePairsToGraph(PrimaryDate,SecondaryDate);
        
        % Calculate all small cycles within the interferogram network
        Cycles = allcycles(GRAPH,'MaxCycleLength',3);

        Ntriplets= length(Cycles);
        for i= 1:min(Ntriplets,MaxTriplets)
            PairStart= Cycles{i};
            PairEnd= circshift(PairStart,-1);
            
            CycleDate1= PostingDate(PairStart(1));
            CycleDate2= PostingDate(PairStart(2));
            CycleDate3= PostingDate(PairStart(3));
            
            [fileCycleDate1,fileCycleDate2,fileCycleDate3]= loadCycleDates(L2filename,Mission,Track);
            
            I= CycleDate1 == fileCycleDate1 & CycleDate2 == fileCycleDate2 & CycleDate3 == fileCycleDate3;

            if any(I)
                fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d already processed. Elapsed time %0.1fmin.\n',...
                    m,length(Missions),t,length(Tracks),i,Ntriplets,(toc-t2)/60)
                continue
            end

            Cu= zeros(grid.Size,'single');
            success= true;
            
            for p= 1:length(PairStart)
                pair= [PairStart(p) PairEnd(p)];
                flipped= pair(2) < pair(1);
                if flipped
                    pair= pair([2 1]);
                end
                
                u= find(PrimaryDate == PostingDate(pair(1)) & SecondaryDate == PostingDate(pair(2)),1);
                
                if isempty(u)
                    fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d could not be constructed.\n',...
                        m,length(Missions),t,length(Tracks),i,Ntriplets)
                    success= false;
                    break
                end
                
                try
                    LOS= io.loadL1Stack(...
                        L1filename,Mission,Track,PrimaryDate(u),SecondaryDate(u));
                catch
                    success= false;
                    fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d interferograms could not be loaded.\n',...
                        m,length(Missions),t,length(Tracks),i,Ntriplets)
                    break
                end
                
                Cu= Cu+ ((-1)^flipped)*LOS;
            end
            
            if success
                saveClosure(L2filename,Mission,Track,CycleDate1,CycleDate2,CycleDate3,Cu)
                
                fprintf('Mission %d/%d. Track %d/%d. Triplet %d/%d processed. Elapsed time %0.1fmin.\n',...
                    m,length(Missions),t,length(Tracks),i,Ntriplets,(toc-t2)/60)
            end
        end

    end
end

end






%% Save

function saveClosure(L2filename,Mission,Track,CycleDate1,CycleDate2,CycleDate3,closure)

basepath= '/interferogram/L2';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

[fileCycleDate1,fileCycleDate2,fileCycleDate3]= loadCycleDates(L2filename,Mission,Track);

I= CycleDate1 == fileCycleDate1 & CycleDate2 == fileCycleDate2 & CycleDate3 == fileCycleDate3;

if any(I)
    k= find(I,1);
else
    k= length(I)+ 1;
end

h5.write2DInf(L2filename,path,'closure',closure,k);
h5.writeatts(L2filename,path,'closure','description','Closure phase')

h5.writeScalar(L2filename,path,'cycleDate1',CycleDate1,Inf,k)
h5.writeScalar(L2filename,path,'cycleDate2',CycleDate2,Inf,k)
h5.writeScalar(L2filename,path,'cycleDate3',CycleDate3,Inf,k)

end


function [CycleDate1,CycleDate2,CycleDate3]= loadCycleDates(filename,Mission,Track)

basepath= '/interferogram/L2';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

CycleDate1= h5.read(filename,path,'cycleDate1');
CycleDate2= h5.read(filename,path,'cycleDate2');
CycleDate3= h5.read(filename,path,'cycleDate3');

if isempty(CycleDate1); CycleDate1= NaT(0); end
if isempty(CycleDate2); CycleDate2= NaT(0); end
if isempty(CycleDate3); CycleDate3= NaT(0); end

end

