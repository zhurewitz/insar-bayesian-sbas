%% Plotting Workflow


workdir= "/Volumes/Zel's Work Drive/Work/CV-ARIA5-BOTH2";

Flag= "L1";
Mission= "S1";
Track= 144;

k= 10;



%% Plot

switch Flag
    case "L1"
        h5filename= fullfile(workdir,'processingStoreL1.h5');
    case "L2"
        h5filename= fullfile(workdir,'processingStoreL2.h5');
    case "L3"
        h5filename= fullfile(workdir,'processingStoreL3.h5');
end

[PrimaryDates,SecondaryDates]= io.loadDates(h5filename,Flag,Mission,Track);


PrimaryDate= PrimaryDates(k);
SecondaryDate= SecondaryDates(k);

figure(1)
[h,illuminationImage]= plt.plotInterferogram( ...
    h5filename,Flag,Mission,Track,PrimaryDate,SecondaryDate);





