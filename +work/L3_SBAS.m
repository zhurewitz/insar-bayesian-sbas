%% L3 Processing - SBAS Timeseries

load input.mat workdir

InputFile= fullfile(workdir,"L2referenced.h5");
SBASFile= fullfile(workdir,"L3SBAStimeseries.h5");
ResidualFile= fullfile(workdir,"L3residual.h5");
OutputFile= fullfile(workdir,"L3output.mat");


%%


[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

[GridLong,GridLat,DatePairs]= d3.readXYZ(InputFile);


saveVariableMATFile(OutputFile,"GridLong",GridLong)
saveVariableMATFile(OutputFile,"GridLat",GridLat)



%% Calculate SBAS Timeseries

figure(1)
h= imagesc(nan(Size(1:2)));
setOptions
colorbar
clim([0 5])


tic
for j= 1:ChunkCount(1)
    for i= 1:ChunkCount(2)
        
        % Read interferogram stack
        [SubStack,SubLong,SubLat,~]= d3.readChunkStack(InputFile,j,i);
        
        if all(isnan(SubStack),'all')
            fprintf("Tile %d/%d is empty. Elapsed time %0.1f min\n", ...
                (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
            continue
        end
        
        % Remove any missing interferograms
        Ipresent= squeeze(any(~isnan(SubStack),[1 2]));
        SubStack= SubStack(:,:,Ipresent);
        DatePairs= DatePairs(Ipresent,:);
        
        PrimaryDate= DatePairs(:,1);
        SecondaryDate= DatePairs(:,2);

        % Flatten interferogram stack
        [FlatStack,SubSize,Iflat]= utils.flatten(SubStack);

        % SBAS Inversion
        [PostingDate,SBASTimeseries,ReferenceDate,Residual,RMSE]= ...
            postingSBASTimeseries(FlatStack,PrimaryDate,SecondaryDate);

        % Append reference date
        PostingDate= [ReferenceDate; PostingDate]; %#ok<AGROW>
        SBASTimeseries= [zeros(1,width(SBASTimeseries)); SBASTimeseries]; %#ok<AGROW>

        % Unflatten SBAS Timeseries
        SBASTimeseriesFull= single(utils.unflatten(SBASTimeseries,SubSize,Iflat));
        ResidualFull= single(utils.unflatten(Residual,SubSize,Iflat));
        RMSEFull= single(utils.unflatten(RMSE,SubSize,Iflat));
        
        
        % Save SBAS Timeseries
        d3.writeChunkStack(SBASFile,SBASTimeseriesFull,j,i,GridLong,GridLat,PostingDate,ChunkSize)
        d3.writeChunkStack(ResidualFile,ResidualFull,j,i,GridLong,GridLat,DatePairs,ChunkSize)
        RMSEPlot= saveChunkMATFile2(OutputFile,"RMSE",RMSEFull,j,i,ChunkSize,Size);
        
        h.CData= RMSEPlot;
        drawnow
        
        fprintf("Calculated SBAS timeseries for tile %d/%d. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
    end
end




%%

load(OutputFile)


figure(2)
h= imagesc(GridLong,GridLat,RMSE);
setOptions
colorbar
clim([0 2])

