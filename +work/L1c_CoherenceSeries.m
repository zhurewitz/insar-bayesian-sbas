
load input.mat workdir

InputFile= fullfile(workdir,"L1coherence.h5");
OutputFile= fullfile(workdir,"L1coherenceStatisticsSeries.mat");

CoherenceFile= fullfile(workdir,"L1CoherenceMask");

load(CoherenceFile,"CoherenceMask")


%%
[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

Ninf= Size(3);

[~,~,DatePairs]= d3.readXYZ(InputFile);

saveVariableMATFile(OutputFile,"DatePairs",DatePairs)



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
    saveVariableMATFile(OutputFile,"MeanCoherence",MeanCoherence,k);
    saveVariableMATFile(OutputFile,"MedianCoherence",MedianCoherence,k)
    saveVariableMATFile(OutputFile,"StdCoherence",StdCoherence,k)
    saveVariableMATFile(OutputFile,"Fraction5",Fraction5,k)
    saveVariableMATFile(OutputFile,"Fraction7",Fraction7,k)
    saveVariableMATFile(OutputFile,"Fraction9",Fraction9,k);
    saveVariableMATFile(OutputFile,"P10",P10,k)
    saveVariableMATFile(OutputFile,"P30",P30,k)
    saveVariableMATFile(OutputFile,"P90",P90,k)


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


%%
% 
% I= ~any(isnat(DatePairs),2) & Fraction9>.9 & days(diff(DatePairs,1,2)) <= 200;
% % I= ~any(isnat(DatePairs),2) & Fraction9>.95;
% 
% figure(3)
% plotInterferogramNetwork(DatePairs(I,:))
% setOptions
% 
% sum(I)
% 
% % interferogramNetworkIsConnected(DatePairs(I,:))
% 
% 
% 
% 
% 
% %%
% 
% load(OutputFile)
% 
% I= ~any(isnat(DatePairs),2);
% 
% DatePairs= DatePairs(I,:);
% Fraction9= Fraction9(I);
% 
% PostingDate= unique(DatePairs);
% 
% y= 1-Fraction9;
% 
% Ninf= height(DatePairs);
% Nposting= length(PostingDate);
% 
% K= zeros(Ninf,2);
% for i= 1:Ninf
%     K(i,1)= find(PostingDate == DatePairs(i,1),1);
%     K(i,2)= find(PostingDate == DatePairs(i,2),1);
% end
% 
% z= {};
% for i= 1:Nposting   
%     z{i}= y(any(K == i,2)); %#ok<SAGROW>
% end
% 
% 
% %%
% 
% [M,I]= maxk(cellfun(@(x) mean(x > .2),z),10);
% 
% [PostingDate(I-1) PostingDate(I)]
