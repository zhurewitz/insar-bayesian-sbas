



function [TF, DatePairsNext]= removalRecommended(DatePairs,RemovalPair)

[ConnComp, PostingDate, SpanningInf, Forward, Backward]= networkMetrics(DatePairs);

% Remove date and recalculate stats
DatePairs2= setdiff(DatePairs,RemovalPair,"rows","stable");
[ConnComp2, PostingDate2, SpanningInf2, Forward2, Backward2]= networkMetrics(DatePairs2);

TF= true;

% Network has split into more subsets (which is bad)
if ConnComp2 > ConnComp
    TF= false;
end

% Ideal networks have at least two spanning interferograms in each
% interval. If the number of intervals with fewer than two has gone up, the
% network has gotten worse.
if sum(SpanningInf < 2) < sum(SpanningInf2 < 2)
    TF= false;
end
% Similarly, if the number of zero span intervals (no interferogram at
% all!) increases, there is a problem, even if the number of <2 remains
% constant
if sum(SpanningInf < 1) < sum(SpanningInf2 < 1)
    TF= false;
end

% Because an acquisition date can be entirely removed from the network, we
% are being careful to distinguish the two cases
for j= 1:length(PostingDate2)
    i= PostingDate == PostingDate2(j);
    
    if Forward2(j) == 0 && Forward(i) > 0
        TF= false;
    end
    if Backward2(j) == 0 && Backward(i) > 0
        TF= false;
    end
end

if nargout > 1
    if TF
        DatePairsNext= DatePairs2;
    else
        DatePairsNext= DatePairs;
    end
end



end



% Interferogram Network Metrics
function [ConnComp, PostingDate, SpanningInf, Forward, Backward]= networkMetrics(DatePairs)

PostingDate= unique(DatePairs(:));

% Connected components
M= utils.designMatrix_linearSplineDisplacement(DatePairs,PostingDate);
M= M(:,2:end);

Rank= rank(M);
ConnComp= width(M)- Rank+ 1;

% Spanning interferograms at each interval
SpanningInf= work.spanningInterferograms(DatePairs(:,1), DatePairs(:,2));

Nposting= length(PostingDate);

% Forwards and backwards interferograms at each acquisition
Forward= zeros(Nposting,1);
Backward= zeros(Nposting,1);
for i= 1:Nposting
    Forward(i)= sum(PostingDate(i) == DatePairs(:,1));
    Backward(i)= sum(PostingDate(i) == DatePairs(:,2));
end

end