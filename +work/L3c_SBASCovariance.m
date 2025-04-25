
load input.mat workdir


L2filename= fullfile(workdir,'L2referenced.h5');
L3OutputFile= fullfile(workdir,'L3output.mat');
L3RMSEMaskFile= fullfile(workdir,'L3_RMSEMask.mat');
OutputFile= fullfile(workdir,"L3_SBASCovariance.mat");



%% Load

[~,~,DatePairs]= d3.readXYZ(L2filename);

load(L3OutputFile,"RMSE")
load(L3RMSEMaskFile,"RMSEMask")


%% 

% Mask out pixels by RMSE
RMSE(~RMSEMask)= nan;

% Amplitude of interferometric noise (mm)
rinf= rms(RMSE,'all','omitmissing');


PostingDate= unique(DatePairs);
Nposting= length(PostingDate);

% SBAS Matrix
M= utils.designMatrix_linearSplineDisplacement(...
    DatePairs,PostingDate);
M= M(:,2:end);

Ninf= height(DatePairs);


Reta= rinf^2*eye(Ninf);

SBASCovariance= inv((M'/Reta)*M);
SBASCovariance= [0 zeros(1,Nposting-1); zeros(Nposting-1,1) SBASCovariance];


save(OutputFile,"SBASCovariance","PostingDate")


%%

load(OutputFile)

figure(1)
pcolor(PostingDate,PostingDate,SBASCovariance)
shading flat
setOptions


figure(2)
plot(PostingDate,sqrt(diag(SBASCovariance)))
setOptions