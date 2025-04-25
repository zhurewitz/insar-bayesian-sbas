
load input.mat workdir

TroposphereFile= fullfile(workdir,"L8troposphere.h5");

[GridLong,GridLat,PostingDate]= d3.readXYZ(TroposphereFile);

if ~exist("Troposphere",'var')
    Troposphere= d3.read(TroposphereFile);
end

load Elevation.mat Elevation

%%

% Dx= diff(Troposphere,1,2);
% Dy= diff(Troposphere,1,1);

% GX= [Dx(:,1,:) .5*(Dx(:,1:end-1,:)+ Dx(:,2:end,:)) Dx(:,end,:)];


Nposting= length(PostingDate);

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

%%

p= (A'*A)\(A'*TropFlat);

Slope= p(1,:);

RMSD= rms(TropFlat-A*p,1);


%%

k= 303;


Page= Troposphere(:,:,k);
Page(~I)= nan;

figure(1)
clf
imagesc(Page)
setOptions


%%

figure(2)
setFigureSize(900,400)
clf
tiledlayoutcompact("",2,3,false)

nexttile([1 2])
plot(PostingDate,Slope,'k','LineWidth',1)
setOptions
ylabel("Slope (mm/km)")

nexttile([2 1])
histogram(Slope,30,'FaceColor','k')
xlabel("Slope (mm/km)")
ylabel("Count")
setOptions

nexttile([1 2])
plot(PostingDate,RMSD,'k','LineWidth',1)
setOptions
ylabel("RMSD (mm)")
setOptions

savePDF("Figures/stratified.pdf")




Iwinter= any(month(PostingDate) == [12 1 2],2);
Isummer= any(month(PostingDate) == [6 7 8],2);


fprintf('All: %0.1f %c %0.1f\n',mean(Slope), char(177), std(Slope))
fprintf('Winter: %0.1f %c %0.1f\n',mean(Slope(Iwinter)), char(177), std(Slope(Iwinter)))
fprintf('Summer: %0.1f %c %0.1f\n',mean(Slope(Isummer)), char(177), std(Slope(Isummer)))
fprintf('Summer exluding outlier: %0.1f %c %0.1f\n',mean(Slope(Isummer & Slope' < 60)), char(177), std(Slope(Isummer & Slope' < 60)))
disp(" ")

