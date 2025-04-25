

load input.mat workdir
L3OutputFile= fullfile(workdir,"L3output.mat");
RMSEMaskFile= fullfile(workdir,"L3_RMSEMask.mat");

%%

load(L3OutputFile)

RMSEMask= RMSE <= 2; 

save(RMSEMaskFile,"RMSEMask","GridLong","GridLat")


%%

load GNSS3LOS_cov.mat StationLatitude StationLongitude ID

figure(1)
imagesc(GridLong,GridLat,RMSEMask)
setOptions
colorbar
% clim([0 4])

hold on
scatter(StationLongitude,StationLatitude,100,'k','filled','Marker','diamond')
hold off
setOptions
colorbar
text(StationLongitude+.02,StationLatitude,ID,"FontSize",14,'FontName',"Times")






