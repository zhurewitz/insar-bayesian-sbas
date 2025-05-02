%% Level 2 Processing - Referencing

function L3a_CutInterferograms(workdir)

arguments
    workdir
end

ChunkSize= [200 200 1];

InputFile= fullfile(workdir,"L2referenced.h5");
CutFile= fullfile(workdir,"L3datePairsCut.mat");
InterferogramFile= fullfile(workdir,"L3cut.h5");


%% Load

% Load grid
[GridLong,GridLat,DatePairs]= d3.readXYZ(InputFile);
Ninf= height(DatePairs);

load(CutFile,"DatePairsCut")



%% Referencing


tic
count= 1;
for k= 1:Ninf
    % Reject missing interferograms
    if any(isnat(DatePairs(k,:)),2)
        fprintf("No data for interferogram %d/%d. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    if any(all(DatePairs(k,:) == DatePairsCut,2))
        fprintf("Cutting interferogram %d/%d. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    
    % Load interferogram
    Interferogram= d3.readPage(InputFile,k);
    
    % No data
    if all(isnan(Interferogram),'all')
        fprintf("No data for interferogram %d/%d. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
        continue
    end
    
    
    % Save interferogram
    d3.writePage(InterferogramFile,Interferogram,count,GridLong,GridLat,DatePairs(k,:),ChunkSize)

    count= count+1;
    fprintf("Referenced interferogram %d/%d saved. Elapsed time %0.1f min\n", ...
        k,Ninf,toc/60)
end


end

