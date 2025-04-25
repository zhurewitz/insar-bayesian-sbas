
load input.mat workdir

InputFile= fullfile(workdir,"L1coherence.h5");
OutputFile= fullfile(workdir,"L1coherenceStatistics.mat");


%%

[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

[GridLong,GridLat,~]= d3.readXYZ(InputFile);


saveVariableMATFile(OutputFile,"GridLat",GridLat)
saveVariableMATFile(OutputFile,"GridLong",GridLong)

%%
figure(1)
h= imagesc(nan(Size(1:2)));
setOptions
c= colorbar;
c.Label.String= "Fraction of Coherence > 0.9";
clim([0 1])

tic
for j= 1:ChunkCount(1)
    for i= 1:ChunkCount(2)
        % Read data
        CoherenceStack= d3.readChunkStack(InputFile,j,i);
        
        I= squeeze(~all(isnan(CoherenceStack),[1 2]));
        CoherenceStack= CoherenceStack(:,:,I);

        % Statistics
        MeanCoherence= mean(CoherenceStack,3,'omitmissing');
        MedianCoherence= median(CoherenceStack,3,'omitmissing');
        StdCoherence= std(CoherenceStack,[],3,'omitmissing');

        Fraction5= sum(CoherenceStack > 0.5,3)/Size(3);
        Fraction7= sum(CoherenceStack > 0.7,3)/Size(3);
        Fraction9= sum(CoherenceStack > 0.9,3)/Size(3);

        P10= prctile(CoherenceStack,10,3);
        P30= prctile(CoherenceStack,30,3);
        P90= prctile(CoherenceStack,90,3);

        % Save 
        saveChunkMATFile2(OutputFile,"MeanCoherence",MeanCoherence,j,i,ChunkSize,Size);
        saveChunkMATFile2(OutputFile,"MedianCoherence",MedianCoherence,j,i,ChunkSize,Size)
        saveChunkMATFile2(OutputFile,"StdCoherence",StdCoherence,j,i,ChunkSize,Size)
        saveChunkMATFile2(OutputFile,"Fraction5",Fraction5,j,i,ChunkSize,Size)
        saveChunkMATFile2(OutputFile,"Fraction7",Fraction7,j,i,ChunkSize,Size)
        Data= saveChunkMATFile2(OutputFile,"Fraction9",Fraction9,j,i,ChunkSize,Size);
        saveChunkMATFile2(OutputFile,"P10",P10,j,i,ChunkSize,Size)
        saveChunkMATFile2(OutputFile,"P30",P30,j,i,ChunkSize,Size)
        saveChunkMATFile2(OutputFile,"P90",P90,j,i,ChunkSize,Size)

        h.CData= Data;
        drawnow
        
        fprintf("Calculated coherence statistics for tile %d/%d. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
    end
end

%%


load(OutputFile)

CoherenceMask= Fraction5>.9;
% At least 90% of interferograms have coherences above 0.5

figure(2)
imagesc(GridLong,GridLat,CoherenceMask)
setOptions
colorbar

save coherenceMask.mat GridLong GridLat CoherenceMask

CoherenceFile= fullfile(workdir,"L1CoherenceMask");
save(CoherenceFile,"GridLong","GridLat","CoherenceMask");



