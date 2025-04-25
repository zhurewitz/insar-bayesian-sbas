%% WORK.L2A_REFERENCEGNSS
% Reference the GNSS to the reference stations

load GNSS3LOS.mat ID StationLatitude StationLongitude Nstations Ndate
S= load("GNSS3LOS.mat","Date","GNSSLOS","GNSSLOSUncertainty");
GNSSDate= S.Date;
GNSS= S.GNSSLOS;
GNSSUncertainty= S.GNSSLOSUncertainty;

ReferenceID= readlines("referenceID.txt","EmptyLineRule","skip");


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


[~,ia]= intersect(ID,ReferenceID);

ReferenceValue= mean(GNSSInterp(:,ia),2);

GNSSReferenced= GNSS- ReferenceValue;


figure(1)
tiledlayoutcompact
plot(GNSSDate,GNSS)
setOptions

nexttile
scatter(StationLongitude,StationLatitude,100,mean(~isnan(GNSS)),"filled")
setOptions
colorbar
clim([.98 1])

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

save GNSS4LOSdemean.mat GNSSDate GNSSReferenced ID ReferenceID StationLongitude StationLatitude


