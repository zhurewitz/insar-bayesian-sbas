%% Interferogram Dates

function [Dates,timeForward]= interferogramDates(filename)

[~,name]= fileparts(filename);

S= reshape(split(name,'-'),[],12);

D= reshape(split(S(:,7),'_'),[],2);

date1= datetime(D(:,1),'InputFormat','yyyyMMdd');
date2= datetime(D(:,2),'InputFormat','yyyyMMdd');

timeForward= date2 >= date1;

Dates= sort([date1 date2],2);

end