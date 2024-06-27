%% KMZ Interferogram Workflow

workdir= "/Volumes/Zel's Work Drive/Work/CV-ARIA5-BOTH2";
GoogleEarthDir= '/Users/zhurewit/Workspace/Google Earth/BInSAR Development';


Flag= "L1";
Mission= "S1";
Track= 144;

k= 10;



%% Load and Write Image

switch Flag
    case "L1"
        h5filename= fullfile(workdir,'processingStoreL1.h5');
    case "L2"
        h5filename= fullfile(workdir,'processingStoreL2.h5');
    case "L3"
        h5filename= fullfile(workdir,'processingStoreL3.h5');
end

grid= h5.readGrid(h5filename,'/grid');

LatLim= grid.LatLim;
LongLim= grid.LongLim;


Page= io.loadPage(h5filename,Flag,Mission,Track,k);

RANGE= [-100 100];
backgroundColor= 0;
cmap= colormap2('redblue');
interferogramImage= plt.toColorSimple(Page,single(cmap),RANGE,backgroundColor);

mask= .8*(~isnan(Page))+ .2;


infname= strcat(Mission,'-',string(Track),'-',string(k));

utils.writeKMZImage(GoogleEarthDir,infname,LatLim,LongLim,interferogramImage,mask);

