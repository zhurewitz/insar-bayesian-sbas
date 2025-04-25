%% L5 Processing - Bayesian Estimation

load input.mat workdir

InputFile= fullfile(workdir,"L4SBASreferenced.h5");
TropFile= fullfile(workdir,"L4_TroposphereCovariance.mat");
SBASCovFile= fullfile(workdir,"L3_SBASCovariance.mat");
DispCovFile= fullfile(workdir,"L5_StochasticCovariance.mat");

OptimizerFile= fullfile(workdir,"L5posteriorMean.h5");
ResidualFile= fullfile(workdir,"L5residual.h5");
OutputFile= fullfile(workdir,"L5output.mat");


% Load info
[ChunkCount,ChunkSize,Size]= d3.chunkInfo(InputFile);

% Load grid
[GridLong,GridLat,PostingDate]= d3.readXYZ(InputFile);

% Save to output file
if exist(OutputFile,"file")
    save(OutputFile,"GridLat","GridLong","-append")
else
    save(OutputFile,"GridLat","GridLong")
end



%% Bayesian Inversion Setup


% Output Dates
Date= (PostingDate(1):6:PostingDate(end))';

Ndate= length(Date);


% Residual Displacement Covariance
load(DispCovFile,"StochasticCovariance")

% Parameter Matrix
ReferenceDate= datetime(2015,1,1);
A= utils.parameterMatrix2(Date,1,1,1,0,0,ReferenceDate,1.8);

% Data availability matrix
G= double(PostingDate == Date');



% Load Error Covariances
load(SBASCovFile,"SBASCovariance")
load(TropFile,"TroposphereCovariance")

% Error Covariance
R_x= TroposphereCovariance+ SBASCovariance;



% Parameter Prior Covariance
ParameterCovariance= 20000*eye(4);

% Prior Covariance
Bx= A*ParameterCovariance*A'+ StochasticCovariance;



% Kalman Gain
K= Bx*G'/(G*Bx*G'+ R_x);

% Posterior Covariance
PosteriorCovariance= (eye(Ndate)- K*G)*Bx;


% Save
save(OutputFile,"Date","PosteriorCovariance","-append")




%%

figure(1)
h= imagesc(GridLong,GridLat,nan(Size(1:2)));
setOptions
c= colorbar;
c.Label.String= "RMSE (mm)";

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
        
        % Bayesian timeseries inversion
        OptimizerFlat= K*SBASTimeseriesFlat;
        
        % Residual
        ResidualFlat= SBASTimeseriesFlat- G*OptimizerFlat;
        
        % RMSE
        RMSEFlat= rms(ResidualFlat,1,"omitmissing");
        
        % Unflatten 
        Optimizer= single(unflatten(OptimizerFlat',SubSize,Iflat));
        Residual= single(utils.unflatten(ResidualFlat,SubSize,Iflat));
        RMSEchunk= single(utils.unflatten(RMSEFlat,SubSize,Iflat));
        
        % Save
        d3.writeChunkStack(OptimizerFile,Optimizer,j,i,GridLong,GridLat,Date,ChunkSize)
        d3.writeChunkStack(ResidualFile,Residual,j,i,GridLong,GridLat,PostingDate,ChunkSize)
        RMSE= saveChunkMATFile2(OutputFile,"RMSE",RMSEchunk,j,i,ChunkSize,Size);
        
        
        fprintf("Bayesian timeseries inversion for tile %d/%d complete. Elapsed time %0.1f min\n", ...
            (j-1)*ChunkCount(2) + i,ChunkCount(1)*ChunkCount(2),toc/60)
        
        
        % Plot
        h.CData= RMSE;
        drawnow
    end
end

