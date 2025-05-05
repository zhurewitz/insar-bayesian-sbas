%% L4 Processing - Temporally Referencing the SBAS Timeseries

function L4_TReference(workdir,parameterFunction,Plot)

arguments
    workdir 
    parameterFunction 
    Plot= false;
end


InputFile= fullfile(workdir,"L3SBAStimeseries.h5");
MaskFile= fullfile(workdir,"L3_RMSEMask.mat");

SBASFile= fullfile(workdir,"L4SBASreferenced.h5");
ResidualFile= fullfile(workdir,"L4residual.h5");
OutputFile= fullfile(workdir,"L4output.mat");




%% Load

load(MaskFile,"RMSEMask")

[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

[GridLong,GridLat,PostingDate]= d3.readXYZ(InputFile);


work.saveVariableMATFile(OutputFile,"GridLong",GridLong)
work.saveVariableMATFile(OutputFile,"GridLat",GridLat)







%% Reference SBAS Timeseries

A= parameterFunction(PostingDate);

ConstantIndex= find(all(A == 1), 1);


if Plot
    clf
    h= imagesc(GridLong,GridLat,nan(Size(1:2)));
    setOptions
    c= colorbar;
    c.Label.String= "Velocity (mm/yr)";
    clim([-3 3])
end

tic
for j= 1:ChunkCount(1)
    for i= 1:ChunkCount(2)
        % Read SBAS timeseries
        SBASTimeseries= d3.readChunkStack(InputFile,j,i);
        
        % Crop RMSE Mask
        [J,I]= d3.chunkIndices(ChunkSize,j,i,1,Size);
        RMSEMaskCrop= RMSEMask(J,I);
        
        % APPLY RMSE MASK
        SBASTimeseries(repmat(~RMSEMaskCrop,1,1,Size(3)))= nan;
        
        if all(isnan(SBASTimeseries),'all')
            fprintf("Tile %d/%d is empty. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
            continue
        end
        
        % Flatten interferogram stack
        [SBASTimeseriesFlat,SubSize,Iflat]= utils.flatten(SBASTimeseries);
        
        % Fit parameters
        [ParametersFlat,~,ResidualFlat,RMSEFlat]= utils.fitParams(SBASTimeseriesFlat,A);
        
        % Unflatten 
        ParametersChunk= single(utils.unflatten(ParametersFlat,SubSize,Iflat));
        ConstantChunk= ParametersChunk(:,:,ConstantIndex);
        Residual= single(utils.unflatten(ResidualFlat,SubSize,Iflat));
        RMSEChunk= single(utils.unflatten(RMSEFlat,SubSize,Iflat));

        % Reference by removing constant
        SBASTimeseries= SBASTimeseries- ConstantChunk;
        
        % Save
        d3.writeChunkStack(SBASFile,SBASTimeseries,j,i,GridLong,GridLat,PostingDate,ChunkSize)
        d3.writeChunkStack(ResidualFile,Residual,j,i,GridLong,GridLat,PostingDate,ChunkSize)
        Parameters= work.saveChunkMATFile2(OutputFile,"Parameters",ParametersChunk,j,i,ChunkSize,Size);
        work.saveChunkMATFile2(OutputFile,"RMSE",RMSEChunk,j,i,ChunkSize,Size);
        
        
        fprintf("Referenced SBAS timeseries for tile %d/%d. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
        
        
        % Plot
        if Plot
            h.CData= Parameters(:,:,1);
            drawnow
        end
    end
end

