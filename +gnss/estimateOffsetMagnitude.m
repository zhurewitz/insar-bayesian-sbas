%% Estimate GNSS Offset Magnitude
% Estimates an offset in a GNSS timeseries. Offsets can happen for a
% variety of reasons, including equipment change and earthquakes, or for
% unknown reasons. They usually take the form of a Heaviside step function.
% Often it is desirable to correct the GNSS displacement timeseries to
% remove them.
% 
% This function estimates the offset at a single input date. It does not
% auto-detect offsets.
% 
% This function takes a window around the input offset date (default 20
% timesteps). Note that this window will not necessarily be symmetrical if
% there is missing data. It fits a linear trend and Heaviside function
% using linear least-squares. It then returns the Heaviside step ONLY.
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
%   stepSize - (1 x 3) matrix of the offset step size with the same units
%       as the original

function stepSize= estimateOffsetMagnitude(Date,Displacement,OffsetDate,window)

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

end


