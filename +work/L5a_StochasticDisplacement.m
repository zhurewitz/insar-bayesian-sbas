%% L5a - Covariance Scale

load input.mat workdir

InputFile= fullfile(workdir,"L4SBASreferenced.h5");
GNSSFile= "GNSS4LOSdemean.mat";
OutputFile= fullfile(workdir,"L5_StochasticCovariance");


%% Load

load(GNSSFile, "GNSSDate", "GNSSReferenced", "ID")
GNSS= GNSSReferenced;
Nstations= length(ID);


[~,~,PostingDate]= d3.readXYZ(InputFile);

% Output Dates
Date= (PostingDate(1):6:PostingDate(end))';

ReferenceDate= datetime(2015,1,1);

Ndate= length(Date);





% SET TIMESCALE
tau= 30/365*sqrt(2); % yr - Displacement timescale (years)

% Post-seismic timescale
ptau= 1.8;

% Get residual to parameter fit
A0= utils.parameterMatrix2(GNSSDate,1,1,1,0,0,[],ptau);
[~,BestFit,Residual]= utils.fitParams(GNSS,A0);



%% Interpolate GNSS Residual

GNSSInterp= nan(length(GNSSDate),Nstations);

for i= 1:Nstations
    GNSStmp= Residual(:,i);

    Inan= isnan(GNSStmp);

    [Istart,Iend,Value]= utils.uniqueRegions(Inan);
    
    % Crop out dates with missing values, so long as the missing values
    % extend less than 60 days in length
    Icrop= false(length(Istart),1);
    for k= 1:length(Istart)
        I= Istart(k):Iend(k);

        if Value(k) && Iend(k)-Istart(k) < 60
            Icrop(I)= true;
        end
    end
    
    GNSSDate2= GNSSDate(~Icrop);
    GNSS2= GNSStmp(~Icrop);

    
    % Interpolate the cropped data. Only the missing values (<60 days) are
    % interpolated, everything else (including longer missing sections)
    % remains
    GNSSInterp(:,i)= interp1(GNSSDate2,GNSS2,GNSSDate);
end




%%
figure(1)
clf
tiledlayoutcompact("",[],[],false)
for i= 1:Nstations
    nexttile
    plot(GNSSDate,GNSSInterp(:,i))
    title(ID(i))
    setOptions
end



%% Filter GNSS

dt= 1/365;

% Filter timescale differs from covariance timescale by factor of sqrt(2)
tauf= tau/sqrt(2);

% Create filter
tt= 0:365*tauf*5; 
tt= [-flip(tt(2:end)) tt]/365;
F= 1/sqrt(2*pi*tauf^2)*exp(-tt.^2/(2*tauf^2));

% Filter residual
FilteredResidual= nan(length(GNSSDate),Nstations);
for i= 1:Nstations
    FilteredResidual(:,i)= conv(GNSSInterp(:,i),F,'same')*dt;
end


% Covariance Scale : Amplitude (std.) of non-parametric displacement (mm)
bscale= rms(FilteredResidual,'all','omitmissing');

fprintf("Covariance Amplitude : %0.2f mm\n\n",bscale)

t= years(Date- ReferenceDate);

% Prior covariance (mm^2)
StochasticCovariance= bscale^2*exp(-(t-t').^2/(2*tau^2));

% SAVE COVARIANCE
save(OutputFile,"StochasticCovariance","Date","FilteredResidual","GNSSDate")





sta= find(ID == "TOWG",1);

figure(2)
clf
tiledlayoutcompact(ID(sta))
plot(GNSSDate,GNSS(:,sta))
hold on
plot(GNSSDate,BestFit(:,sta))
hold off
setOptions

nexttile
plot(GNSSDate,GNSSInterp(:,sta))
setOptions
ylim(20*[-1 1])

nexttile
plot(tt,F)
setOptions

nexttile
plot(GNSSDate,Residual(:,sta))
hold on
plot(GNSSDate,FilteredResidual(:,sta),'LineWidth',2)
hold off
setOptions
ylim([-5 5])




figure(3)
clf
tiledlayoutcompact
plot(GNSSDate,GNSS)
hold on
plot(GNSSDate,BestFit)
hold off
setOptions

nexttile
plot(GNSSDate,Residual)
setOptions
ylim(20*[-1 1])

nexttile
plot(tt,F)
setOptions

nexttile
plot(GNSSDate,FilteredResidual)
setOptions
ylim([-5 5])




figure(4)
clf
imagesc(Date,Date,StochasticCovariance)
setOptions
colorbar