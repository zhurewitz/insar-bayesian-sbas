%% SBAS Timeseries

function [PostingDate,SBASTimeseries,ReferenceDate,Residual,RMSE,M]= ...
    postingSBASTimeseries(flatStack,PrimaryDate,SecondaryDate)

arguments
    flatStack
    PrimaryDate
    SecondaryDate
end

% SAR acquisition date (may be irregular)
PostingDate= unique([PrimaryDate; SecondaryDate]);
ReferenceDate= PostingDate(1);
PostingDate(1)= [];

% SBAS Matrix
M= utils.designMatrix_linearSplineDisplacement(...
    [PrimaryDate SecondaryDate],[ReferenceDate; PostingDate]);
M= M(:,2:end);

SBASTimeseries= (M'*M)\(M'*flatStack);

Residual= flatStack- M*SBASTimeseries;

RMSE= rms(Residual);

end

