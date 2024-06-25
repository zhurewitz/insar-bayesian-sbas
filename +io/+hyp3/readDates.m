%% Interferogram Dates

function [PrimaryDate,SecondaryDate,TimeForward,TemporalBaseline]= readDates(name)

S= split(name,'_');

datestring1= extractBefore(S(2),'T');
datestring2= extractBefore(S(3),'T');

PrimaryDate= datetime(datestring1,"InputFormat","yyyyMMdd");
SecondaryDate= datetime(datestring2,"InputFormat","yyyyMMdd");

TimeForward= SecondaryDate > PrimaryDate;

% Swap if necessary
if ~TimeForward
    tmp= PrimaryDate;
    PrimaryDate= SecondaryDate;
    SecondaryDate= tmp;
end

TemporalBaseline= days(SecondaryDate- PrimaryDate);

end

