%% L9 Troposphere Timeseries Metrics

load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

OutputFile= fullfile(workdir,"L9tropTimeseries.mat");

[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);
[~,~,Date]= d3.readXYZ(PosteriorFile);

load Elevation.mat Elevation



%% Iterate

Nposting= length(PostingDate);

Page= d3.readPage(TroposphereFile,1);
I= ~isnan(Elevation) & ~isnan(Page);

Npix= sum(I,'all');

E= (Elevation- 1000)/1000;
A1= [ones(Npix,1) E(I)];

Ix= GridLong >= -117.15 & GridLong <= -116.9;
Iy= GridLat >= 35.9 & GridLat <= 36.2;
Ipanamint= I & Ix' & Iy;
A2= [ones(sum(Ipanamint,'all'),1) E(Ipanamint)];



saveVariableMATFile(OutputFile,"PostingDate",PostingDate)

tic
for k= 1%:Nposting
    Page= d3.readPage(TroposphereFile,k);
    
    Var0= var(Page,[],'all','omitmissing');
    
    % All
    y= Page(I);
    p= (A1'*A1)\(A1'*y);
    Slope1= p(2);
    Var1= var(Page- Slope1*E,[],'all','omitmissing');
    
    % Panamint
    y= Page(Ipanamint);
    p= (A2'*A2)\(A2'*y);
    Slope2= p(2);
    Var2= var(Page- Slope2*E,[],'all','omitmissing');
    
    
    saveVariableMATFile(OutputFile,"Variance",Var0,k)
    saveVariableMATFile(OutputFile,"Slope1",Slope1,k)
    saveVariableMATFile(OutputFile,"Variance1",Var1,k)
    saveVariableMATFile(OutputFile,"Slope2",Slope2,k)
    saveVariableMATFile(OutputFile,"Variance2",Var2,k)
    
    
    
    fprintf("Tropospheric delay %d/%d saved. Elapsed time %0.1f min\n", ...
        k,Nposting,toc/60)
end



