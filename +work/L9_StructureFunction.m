%% Structure Function

load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");
[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);

if ~exist("Troposphere",'var')
    Troposphere= d3.read(TroposphereFile);
end

load Elevation.mat Elevation


%% Remove Elevation Trend

Nposting= length(PostingDate);

% Elevation Gradient
[EX,EY]= gradient(Elevation);
EX= EX./(cosd(GridLat).*gradient(GridLong)'*111); % m/km
EY= EY./(gradient(GridLat)*111);
Er= hypot(EX,EY);

I= Er > 100 & GridLong' >= -117.8 & GridLat <= 35.7 & ~isnan(Elevation) & ~isnan(Troposphere(:,:,1));

N= sum(I,'all');

[X,Y]= meshgrid(GridLat- mean(GridLat),GridLong- mean(GridLong));

A= [Elevation(I)/1000 ones(N,1) X(I) Y(I)];

% Flatten
TropFlat= reshape(Troposphere,[],Nposting);
TropFlat= TropFlat(I(:),:);

% Estimate elevation slope
p= (A'*A)\(A'*TropFlat);
Slope= p(1,:);

% Calculate Turbulent Component
Turbulent= Troposphere- reshape(Slope,1,1,[]).*(Elevation-mean(Elevation,'all','omitmissing'))/1000;



%% Plot

figure(1)
h= imagesc(Turbulent(:,:,1));
setOptions

for k= 1:Nposting
    h.CData= Turbulent(:,:,k);
    drawnow
end

%% 


Ix= GridLong >= -117.8;
Iy= GridLat <= 35.7;

CropLong= GridLong(Ix);
CropLat= GridLat(Iy);

TropCrop= Troposphere(Iy,Ix,:);
TurbCrop= Turbulent(Iy,Ix,:);
SizeCrop= size(TurbCrop,[1 2]);



%%
k= 20;
CLIM= [-1 1]*15;

tmp= Troposphere(:,:,k);
tmp(~I)= nan;

figure(11)
tiledlayoutcompact
imagesc(TropCrop(:,:,k))
setOptions
axis off
colormap gray
clim(CLIM)

nexttile
imagesc(TurbCrop(:,:,k))
setOptions
axis off
colormap gray
clim(CLIM)

%%

rng(0)

cx= CropLong(200);
cy= CropLat(100);
az= 50;


r= (0:.1:100);

[ry,rx]= reckon(cy,cx,r/111,az);

dL= 1/1200;

ix= ceil((rx- CropLong(1))/dL);
iy= ceil((ry- CropLat(1))/dL);

IN= ix >= 1 & ix <= SizeCrop(2) & iy >= 1 & iy <= SizeCrop(1);

k= 20;

v= nan(length(r),1);
for j= 1:length(r)
    if IN(j)
        v(j)= TurbCrop(iy(j),ix(j),k);
    end
end

figure(2)
clf
imagesc(CropLong,CropLat,TurbCrop(:,:,k))
hold on
scatter(cx,cy,100,'b','filled')
plot(rx,ry,'b')
setOptions
axis off
colormap gray
clim(CLIM)

% figure(3)
% clf
% imagesc(TurbCrop(:,:,k))
% hold on
% scatter(ix(1),iy(1),100,'k','filled')
% scatter(ix,iy,10,'k','filled')
% setOptions

figure(4)
plot(r,v)
setOptions
xlabel("Distance (km)")
ylabel("Tropospheric Delay (mm)")



%% Plot Multiple

rng(0)

dL= 1/1200;
Niterations= 5000;
r= (0:.1:100)';

rng(0)

k= 20;

V= nan(length(r),Niterations);

for it= 1:Niterations
    cx= CropLong(randi(SizeCrop(2)));
    cy= CropLat(randi(SizeCrop(1)));
    az= 360*rand;

    [ry,rx]= reckon(cy,cx,r/111,az);

    ix= ceil((rx- CropLong(1))/dL);
    iy= ceil((ry- CropLat(1))/dL);

    IN= ix >= 1 & ix <= SizeCrop(2) & iy >= 1 & iy <= SizeCrop(1);

    v= nan(length(r),1);
    for j= 1:length(r)
        if IN(j)
            v(j)= TurbCrop(iy(j),ix(j),k);
        end
    end

    V(:,it)= v- v(1);
end




figure(5)
plot(r,V(:,1:20))
setOptions
xlabel("Distance (km)")
ylabel("Relative Delay (mm)")

figure(6)
clf
hold on
plot(r,rms(V(:,1:50),2,"omitmissing"))
plot(r,rms(V,2,"omitmissing"))
setOptions
xlabel("Distance (km)")
ylabel("RMS (mm)")
legend("N=50","N=5000")
box on


%% STRUCTURE FUNCTION FOR ALL DATES

rng(0)

dL= 1/1200;
Niterations= 5000;
r= (0:.1:100)';

S= nan(Nposting,length(r));

for k= 1:Nposting
    V= nan(length(r),Niterations);

    for it= 1:Niterations
        cx= CropLong(randi(SizeCrop(2)));
        cy= CropLat(randi(SizeCrop(1)));
        az= 360*rand;

        [ry,rx]= reckon(cy,cx,r/111,az);

        ix= ceil((rx- CropLong(1))/dL);
        iy= ceil((ry- CropLat(1))/dL);

        IN= ix >= 1 & ix <= SizeCrop(2) & iy >= 1 & iy <= SizeCrop(1);

        v= nan(length(r),1);
        for j= 1:length(r)
            if IN(j)
                v(j)= TurbCrop(iy(j),ix(j),k);
            end
        end

        V(:,it)= v- v(1);
    end


    S(k,:)= rms(V,2,"omitmissing");
    
    fprintf("Date %d/%d complete.\n", k,Nposting)
end

Distance= r;
StructureFunctionSqrt= S;
StructureFunction= S.^2;

% save StructureFunction.mat Distance StructureFunctionSqrt StructureFunction PostingDate


%% PLOT

load StructureFunction.mat

figure(8)
clf
tiledlayoutcompact
hold on
plot(Distance,StructureFunctionSqrt(100:120,:))
plot(Distance,mean(StructureFunctionSqrt,1),'k','LineWidth',4)
setOptions
xlabel("Distance (km)")
ylabel("RMS (mm)")
box on

nexttile
hold on
plot(Distance,StructureFunctionSqrt(100:120,:))
plot(Distance,mean(StructureFunctionSqrt,1),'k','LineWidth',4)
setOptions
xlabel("Distance (km)")
ylabel("RMS (mm)")
box on
set(gca,'XScale','log','YScale','log')



%% Histogram

figure(9)
clf
tiledlayoutcompact
histogram(StructureFunctionSqrt(:,2:3),20)
xlabel("RMS (mm)")
box on
setOptions
title("Linear - 0.1 km")

nexttile
histogram(log10(StructureFunctionSqrt(:,2:3)),20,'FaceColor','k')
xlabel("log_{10}RMS (mm)")
box on
setOptions
title("Log - 0.1 km")
XTICKS= [.1 .2 .5 1 2 5 10 20 50 100];
xticks(log10(XTICKS))
xticklabels(XTICKS)

nexttile
histogram(StructureFunctionSqrt(:,10:12),20)
xlabel("RMS (mm)")
box on
setOptions
title("Linear - 1 km")

nexttile
histogram(log10(StructureFunctionSqrt(:,10:12)),20,'FaceColor','k')
xlabel("log_{10}RMS (mm)")
box on
setOptions
title("Log - 1 km")
XTICKS= [.1 .2 .5 1 2 5 10 20 50 100];
xticks(log10(XTICKS))
xticklabels(XTICKS)

nexttile
histogram(StructureFunctionSqrt(:,98:104),20)
xlabel("RMS (mm)")
box on
setOptions
title("Linear - 10 km")

nexttile
histogram(log10(StructureFunctionSqrt(:,98:104)),20,'FaceColor','k')
xlabel("log_{10}RMS (mm)")
box on
setOptions
XTICKS= [.1 .2 .5 1 2 5 10 20 50 100];
xticks(log10(XTICKS))
xticklabels(XTICKS)
title("Log - 10 km")

nexttile
histogram(StructureFunctionSqrt(:,990:1000),20)
xlabel("RMS (mm)")
box on
setOptions
title("Linear - 100 km")

nexttile
histogram(log10(StructureFunctionSqrt(:,990:1000)),20,'FaceColor','k')
xlabel("log_{10}RMS (mm)")
box on
setOptions
XTICKS= [.1 .2 .5 1 2 5 10 20 50 100];
xticks(log10(XTICKS))
xticklabels(XTICKS)
title("Log - 100 km")



%%


load StructureFunction.mat


i= 10;

r2= 10.^(-1:.1:2)';
x= log10(r2);
y= log10(interp1(Distance,StructureFunctionSqrt(i,:),r2));
[Mean,Uncertainty,SampleX,Statistics]= simpleLinearRegression(x,y);

figure(15)
clf
tiledlayoutcompact
hold on
plot(Distance,StructureFunctionSqrt(i,:))
setOptions
xlabel("Distance (km)")
ylabel("RMS (mm)")
box on
plot(Distance,10^(Statistics.Intercept)*Distance.^Statistics.Slope,'LineWidth',3,'Color',[.7 .5 .1])

nexttile
hold on
plot(log10(Distance),log10(StructureFunctionSqrt(i,:)))
plot(x,y,'k')
setOptions
xlabel("Distance (km)")
ylabel("RMS (mm)")
box on
plot(SampleX,Mean,'LineWidth',3,'Color',[.7 .5 .1])



%%


load StructureFunction.mat


r2= 10.^(-1:.1:2)';
x= log10(r2);

Y= nan(length(x),Nposting);
for i= 1:Nposting
    Y(:,i)= log10(interp1(Distance,StructureFunctionSqrt(i,:),r2));
end


A= [x ones(length(x),1)];
p= (A'*A)\(A'*Y);
PowerLawExponent= p(1,:)';
PowerLawAmplitude= 10.^p(2,:)';

t= years(PostingDate- datetime(2015,1,1));
B= [ones(Nposting) cos(2*pi*t) sin(2*pi*t)];

[~,BestFitExp]= utils.fitParams(PowerLawExponent, B);
[~,BestFitAmp]= utils.fitParams(PowerLawAmplitude, B);

figure(16)
clf
tiledlayoutcompact
histogram(PowerLawExponent,20)
setOptions
xlabel("Power Law Exponent")

nexttile
hold on
plot(PostingDate,PowerLawExponent,'k')
% plot(PostingDate,BestFitExp,'LineWidth',1)
setOptions
ylabel("Power Law Exponent")
box on

nexttile
histogram(PowerLawAmplitude,20)
setOptions
xlabel("Power Law Amplitude (mm)")

nexttile
hold on
plot(PostingDate,PowerLawAmplitude,'k')
% plot(PostingDate,BestFitAmp,'LineWidth',1)
setOptions
ylabel("Power Law Amplitude (mm)")
box on
