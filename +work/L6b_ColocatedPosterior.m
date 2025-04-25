%% L6b Processing - Bayesian InSAR Timeseries Colocated with GNSS Stations


load input.mat workdir

filename= fullfile(workdir,"L5posteriorMean.h5");
OutputFilename= fullfile(workdir,"L6_ColocatedPosterior.mat");
GNSSFile= "GNSS4LOSdemean.mat";


%%
[GridLong,GridLat,Date]= d3.readXYZ(filename);
Ndate= length(Date);

load(GNSSFile, "StationLatitude", "StationLongitude", "ID")

Nstations= length(ID);

ColocatedPosterior= nan(Ndate,Nstations);
tic
for i= 1:Nstations
    % Default value is 0.5 km
    [f,IX,IY]= gaussianFilter(GridLong,GridLat,StationLongitude(i),StationLatitude(i));
    
    ColocatedPosterior(:,i)= readFiltered(filename,IY,IX,f);
    
    fprintf("Station %d/%d. Elapsed time %0.0fs\n",i,Nstations,toc)
end

save(OutputFilename,"ColocatedPosterior","ID","StationLongitude","StationLongitude","Date")



%%

load GNSS4LOSdemean.mat GNSSDate GNSSReferenced
load(OutputFilename)

figure(1)
plot(GNSSDate,GNSSReferenced,'k')
hold on
plot(Date,ColocatedPosterior)
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

% Check if there is sufficient data (>50%)
if sum(fflat) < .5
    % If not, return NaN values
    ts= nan(size(dataflat,1),1);
    
else
    % Renormalize filter
    fflat= fflat/sum(fflat);
    
    % Filter
    ts= sum(dataflat.*fflat,2);
end


end