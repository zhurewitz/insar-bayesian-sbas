%% Interferogram Mask
% All land pixels within the interferogram frames

function mask= generateInterferogramMask(interferogram)

outside= zeros(size(interferogram));
CC= bwconncomp(isnan(interferogram));
[~,I]= max(cellfun(@length,CC.PixelIdxList));
pixlist= cell2mat(CC.PixelIdxList(I));
outside(pixlist)= 1;

mask= ~outside;

end
