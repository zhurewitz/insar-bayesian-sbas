%% Split GNSS Dataset
% Split GNSS stations into training, testing, and validating datasets in a
% repeatable manner. 

function splitDataset(workdir,trainPercentage,testPercentage)

arguments
    workdir
    trainPercentage
    testPercentage= 0;
end

allStationsFilename= fullfile(workdir,'GNSS/allGNSSstations.txt');

StationID= readlines(allStationsFilename);
StationID(StationID == "")= [];

N= length(StationID);
Ntrain= ceil(N*trainPercentage/100);
Ntest= ceil(N*testPercentage/100);

rng(0,'twister')
[~,I]= sort(rand(N,1));

TrainID= sort(StationID(I(1:Ntrain)));
TestID= sort(StationID(I(Ntrain+(1:Ntest))));
ValidateID= sort(StationID(I(Ntrain+Ntest+1:end)));


TrainFilename= fullfile(workdir,'GNSS/trainStations.txt');
TestFilename= fullfile(workdir,'GNSS/testStations.txt');
ValidateFilename= fullfile(workdir,'GNSS/validateStations.txt');

writelines(TrainID,TrainFilename)
writelines(TestID,TestFilename)
writelines(ValidateID,ValidateFilename)

end
