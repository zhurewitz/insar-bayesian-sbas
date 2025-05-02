%% WORK.L1C_COHERENCESERIES
% Temporal coherence statistics

function OutputFile= L1c_CoherenceSeries(workdir,Plot)

arguments
    workdir= [];
    Plot= true;
end

InputFile= fullfile(workdir,"L1coherence.h5");
OutputFile= fullfile(workdir,"L1coherenceStatisticsSeries.mat");

CoherenceMaskFile= fullfile(workdir,"L1CoherenceMask.mat");

if ~exist(CoherenceMaskFile,'file')
    error("Coherence mask file %s does not exist",CoherenceMaskFile)
end
try
    load(CoherenceMaskFile,"CoherenceMask")
catch ME
    error("Could not find variable CoherenceMask in file %s",CoherenceMaskFile)
end

Size= size(CoherenceMask);

[~,~,DatePairs]= d3.readXYZ(InputFile);

work.saveVariableMATFile(OutputFile,"DatePairs",DatePairs)

if Plot
    h= imagesc(nan(Size(1:2)));
    setOptions
    c= colorbar;
    c.Label.String= "Coherence";
    clim([.7 1])
end


tic
Ninf= height(DatePairs);
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
    work.saveVariableMATFile(OutputFile,"Pixels",Npix,k);
    work.saveVariableMATFile(OutputFile,"MeanCoherence",MeanCoherence,k);
    work.saveVariableMATFile(OutputFile,"MedianCoherence",MedianCoherence,k)
    work.saveVariableMATFile(OutputFile,"StdCoherence",StdCoherence,k)
    work.saveVariableMATFile(OutputFile,"Fraction5",Fraction5,k)
    work.saveVariableMATFile(OutputFile,"Fraction7",Fraction7,k)
    work.saveVariableMATFile(OutputFile,"Fraction9",Fraction9,k);
    work.saveVariableMATFile(OutputFile,"P10",P10,k)
    work.saveVariableMATFile(OutputFile,"P30",P30,k)
    work.saveVariableMATFile(OutputFile,"P90",P90,k)

    if Plot
        h.CData= CoherencePage;
        drawnow
    end
    
    fprintf("Calculated coherence statistics for interferogram %d/%d. Elapsed time %0.1f min\n", ...
            k,Ninf,toc/60)
end



end