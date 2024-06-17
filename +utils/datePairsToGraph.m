%% Date Pairs to Graph
% Generates interferogram graph/network from a set of primary/secondary
% dates

function [Date,G]= datePairsToGraph(PrimaryDate,SecondaryDate)

Date= unique([PrimaryDate; SecondaryDate]);

Ndate= length(Date);


I1= sum((PrimaryDate == Date').*(1:Ndate),2);
I2= sum((SecondaryDate == Date').*(1:Ndate),2);

A= false(Ndate);

for i= 1:height(I1)
    A(I1(i),I2(i))= true;
end

A= A | A';

G= graph(A);

end