%% L6 Processing - Parameter Fit

load input.mat workdir

InputFile= fullfile(workdir,"L5posteriorMean.h5");

ResidualFile= fullfile(workdir,"L6residual.h5");
OutputFile= fullfile(workdir,"L6output.mat");




%% Load

[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

[GridLong,GridLat,Date]= d3.readXYZ(InputFile);


saveVariableMATFile(OutputFile,"GridLong",GridLong)
saveVariableMATFile(OutputFile,"GridLat",GridLat)







%% Parameter Fit

A= utils.parameterMatrix2(Date,1,1,1,0,0,datetime(2015,1,1),1.8);


figure(1)
h= imagesc(GridLong,GridLat,nan(Size(1:2)));
setOptions
c= colorbar;
c.Label.String= "Velocity (mm/yr)";
clim([-5 5])

tic
for j= 1:ChunkCount(1)
    for i= 1:ChunkCount(2)
        % Read SBAS timeseries
        SBASTimeseries= d3.readChunkStack(InputFile,j,i);
        
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
        Parameters= single(utils.unflatten(ParametersFlat,SubSize,Iflat));
        VelocityChunk= Parameters(:,:,1);
        ConstantChunk= Parameters(:,:,2);
        CoseismicChunk= Parameters(:,:,3);
        PostSeismicChunk= Parameters(:,:,4);
        Residual= single(utils.unflatten(ResidualFlat,SubSize,Iflat));
        RMSEChunk= single(utils.unflatten(RMSEFlat,SubSize,Iflat));
        
        % Save
        d3.writeChunkStack(ResidualFile,Residual,j,i,GridLong,GridLat,Date,ChunkSize)
        
        Velocity= saveChunkMATFile2(OutputFile,"Velocity",VelocityChunk,j,i,ChunkSize,Size);
        Constant= saveChunkMATFile2(OutputFile,"Constant",ConstantChunk,j,i,ChunkSize,Size);
        Coseismic= saveChunkMATFile2(OutputFile,"Coseismic",CoseismicChunk,j,i,ChunkSize,Size);
        PostSeismic= saveChunkMATFile2(OutputFile,"PostSeismic",PostSeismicChunk,j,i,ChunkSize,Size);
        RMSE= saveChunkMATFile2(OutputFile,"RMSE",RMSEChunk,j,i,ChunkSize,Size);
        
        
        fprintf("Fit parameters for SBAS timeseries for tile %d/%d. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
        
        
        % Plot
        h.CData= Velocity;
        drawnow
    end
end


%%

load(OutputFile)

figure(1)
imagesc(GridLong,GridLat,Velocity);
setOptions
c= colorbar;
c.Label.String= "Velocity (mm/yr)";
clim([-1 1]*5)

figure(2)
imagesc(GridLong,GridLat,Coseismic);
setOptions
c= colorbar;
c.Label.String= "Coseismic Displacement (mm)";
clim([-1 1]*500)

figure(3)
imagesc(GridLong,GridLat,Constant);
setOptions
c= colorbar;
c.Label.String= "Displacement Constant (mm)";
clim([-1 1]*2)


figure(4)
imagesc(GridLong,GridLat,PostSeismic*.4);
setOptions
c= colorbar;
c.Label.String= "Postseismic Displacement @ 1yr (mm)";
clim([-1 1]*30)


figure(5)
imagesc(GridLong,GridLat,RMSE);
setOptions
c= colorbar;
c.Label.String= "RMSE (mm)";
clim([0 1])