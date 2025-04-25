
load input.mat workdir

InputFile= fullfile(workdir,"L1coherence.h5");
OutputFile= fullfile(workdir,"L1coherenceStatisticsSeries.mat");

CoherenceFile= fullfile(workdir,"L1CoherenceMask");

load(CoherenceFile,"CoherenceMask")


%%
[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

Ninf= Size(3);

[~,~,DatePairs]= d3.readXYZ(InputFile);

work.saveVariableMATFile(OutputFile,"DatePairs",DatePairs)



%%
figure(1)
h= imagesc(nan(Size(1:2)));
setOptions
c= colorbar;
c.Label.String= "Coherence";
clim([.7 1])

tic
for k= 1:Ninf
    CoherencePage= d3.readPage(InputFile,k);
    
    if all(isnan(CoherencePage),'all')
        fprintf("Missing data for %d/%d\n",k,Ninf)
        continue
    end
    
    CoherencePage(~CoherenceMask)= nan;
    
    Npix= sum(~isnan(CoherencePage),'all');
    
    % Statistics
    MeanCoherence= mean(CoherencePage,'all','omitmissing');
    MedianCoherence= median(CoherencePage,'all','omitmissing');
    StdCoherence= std(CoherencePage,[],'all','omitmissing');

    Fraction5= sum(CoherencePage > 0.5,'all','omitmissing')/Npix;
    Fraction7= sum(CoherencePage > 0.7,'all','omitmissing')/Npix;
    Fraction9= sum(CoherencePage > 0.9,'all','omitmissing')/Npix;

    P10= prctile(CoherencePage,10,'all');
    P30= prctile(CoherencePage,30,'all');
    P90= prctile(CoherencePage,90,'all');
    
    % Save
    work.saveVariableMATFile(OutputFile,"MeanCoherence",MeanCoherence,k);
    work.saveVariableMATFile(OutputFile,"MedianCoherence",MedianCoherence,k)
    work.saveVariableMATFile(OutputFile,"StdCoherence",StdCoherence,k)
    work.saveVariableMATFile(OutputFile,"Fraction5",Fraction5,k)
    work.saveVariableMATFile(OutputFile,"Fraction7",Fraction7,k)
    work.saveVariableMATFile(OutputFile,"Fraction9",Fraction9,k);
    work.saveVariableMATFile(OutputFile,"P10",P10,k)
    work.saveVariableMATFile(OutputFile,"P30",P30,k)
    work.saveVariableMATFile(OutputFile,"P90",P90,k)


    h.CData= CoherencePage;
    drawnow
    
    fprintf("Calculated coherence statistics for interferogram %d/%d. Elapsed time %0.1f min\n", ...
            k,Ninf,toc/60)
end


%%

load(OutputFile)


figure(2)
scatter(mean(DatePairs,2),days(diff(DatePairs,1,2)),50,1-Fraction9,'filled')
setOptions
c= colorbar;
c.Label.String= "Fraction of Coherence < 0.9";
clim([0 .1])

