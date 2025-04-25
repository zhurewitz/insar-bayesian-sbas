%% L8 Troposphere Timeseries

load input.mat workdir

SBASFile= fullfile(workdir,"L4SBASreferenced.h5");
PosteriorFile= fullfile(workdir,"L5posteriorMean.h5");

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

[GridLong,GridLat,PostingDate]= d3.readXYZ(SBASFile);
[~,~,Date]= d3.readXYZ(PosteriorFile);


%% Iterate

Nposting= length(PostingDate);

tic
for k= 1:Nposting
    k2= find(PostingDate(k) == Date,1);
    
    Page1= d3.readPage(SBASFile,k);
    Page2= d3.readPage(PosteriorFile,k2);
    
    Troposphere= Page1-Page2;
    
    d3.writePage(TroposphereFile,Troposphere,k,GridLong,GridLat,PostingDate(k));
    
    fprintf("Tropospheric delay %d/%d saved. Elapsed time %0.1f min\n", ...
        k,Nposting,toc/60)
end



