%% Correct GNSS Offset
% Corrects an offset in a GNSS timeseries. Offsets can happen for a variety
% of reasons, including equipment change and earthquakes, or for unknown
% reasons. They take the form of a Heaviside step function. Often it is
% desirable to correct the GNSS displacement timeseries to remove them. 
% 
% This function corrects the timeseries for a single input offset date. It
% does not auto-detect offsets.
% 
% This function takes a window around the input offset date (default 20
% timesteps). Note that this window will not necessarily be symmetrical if
% there is missing data. It fits a linear trend and Heaviside function
% using linear least-squares. It then removes the Heaviside step ONLY and
% returns the corrected timeseries.
% 
% Input:
%   Date - (N x 1) datetime array of dates corresponding to the GNSS
%       displacement.
%   Displacement - (N x 3) matrix of ENU or XYZ GNSS displacements, any
%       units.
%   OffsetDate - datetime at which the offset took place
%   window (optional, default 20) - integer number of timesteps on either
%       side of the OffsetDate to consider.
% Output:
%   correctedDisplacement - (N x 3) matrix formatted exactly as input, with
%       the same units, of the step-corrected displacement.

function correctedDisplacement= correctOffset(Date,Displacement,OffsetDate,window)

arguments
    Date
    Displacement
    OffsetDate
    window= 20;
end

[~,j]= min(abs(Date- OffsetDate));

% Window
I= max(1,j-window):min(length(Displacement),j+window);

% Parameters
t= days(Date(I)- OffsetDate)/window;
y= Displacement(I,:);

% Parameter inversion matrix
% Fits a linear trend + Heaviside step
A= [ones(length(t),1) t t>0];

% Parameter inversion
params= A\y;

% Step size
stepSize= params(3,:);

correctedDisplacement= Displacement;
correctedDisplacement(Date > OffsetDate,:)= ...
    correctedDisplacement(Date > OffsetDate,:)- stepSize;

end


