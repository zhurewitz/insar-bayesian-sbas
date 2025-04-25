

load GNSS1_cov.mat

i1= find(ID == "P591");
i2= find(ID == "P812");

I= Date >= datetime(2019,1,1) & Date <= datetime(2024,1,1);

Date= Date(I);
E= East(I,i2)- East(I,i1);
N= North(I,i2)- North(I,i1);
U= Up(I,i2)- Up(I,i1);

LookVector= [.60,-.11,.784];
LOS= LookVector(1)*E+ LookVector(2)*N+ LookVector(3)*U;


A= utils.parameterMatrix2(Date,0,1,0,1);
[p,EFit]= utils.fitParams(E,A);
Eamp= hypot(p(3),p(4));
[p,NFit]= utils.fitParams(N,A);
Namp= hypot(p(3),p(4));
[p,UFit]= utils.fitParams(U,A);
Uamp= hypot(p(3),p(4));
[p,LOSFit]= utils.fitParams(LOS,A);
LOSamp= hypot(p(3),p(4));

figure(1)
clf
tiledlayoutcompact
plot(Date,E)
hold on
plot(Date,EFit, 'LineWidth',2)
setOptions

nexttile
plot(Date,N)
hold on
plot(Date,EFit, 'LineWidth',2)
setOptions

nexttile
plot(Date,U)
hold on
plot(Date,EFit, 'LineWidth',2)
setOptions

nexttile
plot(Date,LOS)
hold on
plot(Date,EFit, 'LineWidth',2)
setOptions




