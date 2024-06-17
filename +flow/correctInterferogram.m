%% Correct Interferogram 
% Corrects phase misclosure in interferogram. In those pixels where the
% phase doesn't close (as calculated in processMisclosureMask.m and
% preparePhaseMisclosureMask.m) the value of the interferogram is replaced
% with its low frequency component.
%
% The calculation of the low-frequency component excludes the pixels where
% the phase miscloses.
% 
% In regions where almost all of the pixels are misclosed, the
% low-frequency component becomes ill-defined. To handle this, an
% iterative process is used. The LF component is smoothed again, and the
% problem pixels are replaced by their lower-frequency value, until all
% such pixels are filled.
%
% The low-frequency calculation is performed with moving-mean (boxcar
% filter) in 2D, with missing values excluded. The window is 50 pixels or
% ~5km.
%   
% See correctInterferogram_vis.m for a visualization of the process.

function correctedInterferogram= correctInterferogram(...
    interferogram,closureMask)

% Original Interferogram Mask
originalMask= ~isnan(interferogram);

% Interferogram masked by misclosure
maskedInterferogram= interferogram; 
maskedInterferogram(closureMask)= nan;

% Low frequency component of masked interferogram
lowFrequency= quicksmooth(maskedInterferogram,50);

% Further mask any regions with fewer than 10% of contributing pixels
% actually present
lowMask= quicksmooth(closureMask+0,50) >= .9;

% Mask out those problem pixels
LFMasked= lowFrequency; 
LFMasked(lowMask)= nan;
% Note: LFMasked is the best current estimate of the low-frequency
% component of the interferogram

% Overlap between current NaN and original NaN values
nanOverlap= originalMask & isnan(LFMasked);

it= 0;
while any(nanOverlap,'all')
    if it >= 20
        warning('Convergence not reached within 20 iterations')
        break
    end
    
    % Smoother version of current low-frequency interferogram
    lowFrequency= quicksmooth(LFMasked,100); % Increase smoothing window to 100 to speed convergence
    
    % Remaining problem pixels
    lowMask= quicksmooth(nanOverlap+0,100) >= .9; 
    
    % Replace pixels on boundaries of current problem regions
    replacementMask= nanOverlap & ~lowMask; 
    
    % Replace those NaNs with the smoother version
    LFMasked(replacementMask)= lowFrequency(replacementMask); 
    
    % Remaining problem pixels
    nanOverlap= originalMask & isnan(LFMasked); 
    
    it= it+ 1;
end

% Correct original interferogram by replacing misclosed pixels by
% low-frequency estimate
correctedInterferogram= interferogram;
correctedInterferogram(closureMask)= LFMasked(closureMask);

end




function Y= quicksmooth(X,window)
Y= movmean(movmean(X,window,1,'omitmissing'),window,2,'omitmissing');
end