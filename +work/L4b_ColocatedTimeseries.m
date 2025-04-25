%% L4b Processing - InSAR Timeseries Colocated with GNSS Stations


load input.mat workdir

filename= fullfile(workdir,"L4SBASreferenced.h5");
OutputFilename= fullfile(workdir,"L4_ColocatedInSAR.mat");


%%
[GridLong,GridLat,PostingDate]= d3.readXYZ(filename);
Nposting= length(PostingDate);

load GNSS4LOSdemean.mat StationLatitude StationLongitude ID
Nstations= length(ID);


ColocatedTimeseries= nan(Nposting,Nstations);
tic
for i= 1:Nstations
    % Default value is 0.5 km
    [f,IX,IY]= gaussianFilter(GridLong,GridLat,StationLongitude(i),StationLatitude(i));
    
    c= readFiltered(filename,IY,IX,f);
    if ~isempty(c)
        ColocatedTimeseries(:,i)= c;
    else
        0
    end
    
    fprintf("Station %d/%d. Elapsed time %0.0fs\n",i,Nstations,toc)
end

save(OutputFilename,"ColocatedTimeseries","ID","StationLongitude","StationLongitude","PostingDate")



%%

load GNSS4LOSdemean.mat GNSSDate GNSSReferenced
load(OutputFilename)

figure(1)
plot(GNSSDate,GNSSReferenced,'k')
hold on
plot(PostingDate,ColocatedTimeseries)
hold off
setOptions













%% Gaussian Filter in Lat/Long

function [f,IX,IY,Ix,Iy]= gaussianFilter(Long,Lat,StationLong,StationLat,sigma,filterHalfWidth)

arguments
    Long
    Lat
    StationLong (1,1)
    StationLat (1,1)
    sigma= 0.5;
    filterHalfWidth= 30;
end

% Find station pixel
[~,Ix]= min(abs(Long-StationLong));
[~,Iy]= min(abs(Lat-StationLat));

w= filterHalfWidth;

IX= Ix+ (-w:w);
k= IX < 1 | IX > length(Long);
IX(k)= [];

IY= Iy+ (-w:w);
k= IY < 1 | IY > length(Lat);
IY(k)= [];

[LONG,LAT]= meshgrid(Long(IX),Lat(IY));

% Distance from pixels to station converted from deg. to km
r= 111*distance(LAT,LONG,StationLat,StationLong);

% Gaussian filter
f= exp(-r.^2/(2*sigma^2));

% Normalize
f= f/sum(f,'all');

end




%% Read and Filter

function ts= readFiltered(filename,J,I,f)

data= d3.read(filename,J,I);

% Flatten data
[dataflat,~,Index]= utils.flatten(data,'any');

% Flatten filter
fflat= f(Index)';

% Renormalize filter
fflat= fflat/sum(fflat);

ts= sum(dataflat.*fflat,2);

end