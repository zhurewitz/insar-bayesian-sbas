
load input.mat workdir

InputFilename= fullfile(workdir,"L4_ColocatedInSAR.mat");
GNSSFilename= "GNSS4LOSdemean.mat";
OutputFilename= fullfile(workdir,"L4_TroposphereCovariance.mat");

load GNSS4LOSdemean.mat GNSSDate GNSSReferenced
load(InputFilename)

[~,ia,ib]= intersect(GNSSDate,PostingDate);

GNSS= GNSSReferenced(ia,:);
InSAR= ColocatedTimeseries(ib,:);

ResidualDate= GNSSDate(ia);
ResidualTroposphere= InSAR-GNSS;

% Exclude outlier station P595
Ikeep= ID ~= "P595";

STD= std(ResidualTroposphere(:,Ikeep),[],2,"omitmissing");

A= utils.parameterMatrix2(ResidualDate,0,0,0,1,0);
[Sparams,~,~]= utils.fitParams(STD,A);

A2= utils.parameterMatrix2(GNSSDate,0,0,0,1,0);
BestFit= A2*Sparams;

A3= utils.parameterMatrix2(PostingDate,0,0,0,1,0);
SeasonalFit= A3*Sparams;

TroposphereCovariance= diag(SeasonalFit.^2);

save(OutputFilename,"TroposphereCovariance","PostingDate")


figure(1)
tiledlayoutcompact
plot(ResidualDate,ResidualTroposphere(:,Ikeep))
setOptions

nexttile
plot(ResidualDate,STD)
hold on
plot(GNSSDate,BestFit,"LineWidth",2)
hold off
setOptions















