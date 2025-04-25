

load GNSS3LOS_cov.mat ID StationLatitude StationLongitude Nstations Ndate
S= load("GNSS3LOS_cov.mat","Date","GNSSLOS71","GNSSLOS71Uncertainty");
GNSSDate= S.Date;
GNSS= S.GNSSLOS71;
GNSSUncertainty= S.GNSSLOS71Uncertainty;

GNSSInterp= GNSS;
% Interpolate 
for i= 1:Nstations
    GNSStmp= GNSS(:,i);
    Inan= isnan(GNSStmp);
    
    [Istart,Iend,Value]= utils.uniqueRegions(Inan);
    
    for k= 2:length(Istart)-1
        if Value(k)
            I= Istart(k):Iend(k);
            Ndays= length(I);
            
            if Ndays <= 60
                g1= GNSS(Iend(k-1),i);
                g2= GNSS(Istart(k+1),i);
                
                GNSSInterp(I,i)= g1+ (g2-g1)/(Ndays+1)*(1:Ndays);
            end
        end
    end
end


figure(1)
tiledlayoutcompact
plot(GNSSDate,GNSS)
setOptions

nexttile
scatter(StationLongitude,StationLatitude,100,mean(~isnan(GNSS)),"filled")
setOptions
colorbar
clim([.98 1])

ReferenceID= ID(mean(~isnan(GNSS)) > .98);
ReferenceID= setdiff(ReferenceID,["P595" "P594" "CCCC" "P580"]);

% We select as reference stations all GNSS stations which have fewer than
% 2% missing data points over the time period. We exclude the 5 stations
% closest to the earthquake: P595, CCCC, TOWG, P594, and P580.

[~,ia]= intersect(ID,ReferenceID);

ReferenceValue= mean(GNSSInterp(:,ia),2);

GNSSReferenced= GNSS- ReferenceValue;

nexttile
plot(GNSSDate,GNSSInterp(:,ia))
setOptions

nexttile
plot(GNSSDate,GNSSReferenced)
setOptions

nexttile
scatter(StationLongitude,StationLatitude,100,'r',"filled")
setOptions
colorbar
clim([.98 1])

hold on
scatter(StationLongitude(ia),StationLatitude(ia),20,'k',"filled")
hold off
text(StationLongitude+.02,StationLatitude,ID)

nexttile
plot(GNSSDate,median(GNSSReferenced,2,'omitmissing'))
setOptions


%%
load GNSS3LOS_cov.mat Ix Iy
save GNSS4LOSdemean.mat GNSSDate GNSSReferenced ID StationLongitude StationLatitude
save GNSS4LOSdemean.mat ReferenceID Ix Iy -append 




%% WRITE Reference Stations

ReferenceID= [
    "CPBN"
    "LNMT"
    "P462"
    "P464"
    "P569"
    "P579"
    "P591"
    "P592"
    "P593"
    "P596"
    "P597"
    "P615"
    "P616"
    "P617"
    "RAMT"];

writelines(ReferenceID,"referenceStations.txt")



%% Old Reference Stations
% CPBN
% LNMT
% P464
% P569
% P579
% P591
% P593
% P594
% P596
% P597
% RAMT

