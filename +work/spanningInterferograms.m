
function [SpanningInf,PostingDate,CenterDate]= ...
    spanningInterferograms(PrimaryDate, SecondaryDate)

PostingDate= unique([PrimaryDate; SecondaryDate]);

DatePairs= unique([PrimaryDate SecondaryDate],"rows");

Nposting= length(PostingDate);
x= PostingDate(1:end-1)+ .5*diff(PostingDate);
N= Nposting-1;
y= zeros(N,1);
for i= 1:N
    y(i)= sum(DatePairs(:,1) <= x(i) & x(i) <= DatePairs(:,2));
end

CenterDate= x;
SpanningInf= y;

end