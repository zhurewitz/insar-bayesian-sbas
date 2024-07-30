%% Estimate Displacement Timeseries

function [Optimizer,Date,ReferenceDate,PosteriorCovarianceSqrt,SBASTimeseries]= ...
    estimateDisplacementTimeseries(Stack,PrimaryDate,SecondaryDate)
% Prepare Stack

% SAR acquisition date (may be irregular)
PostingDate= unique([PrimaryDate; SecondaryDate]);
ReferenceDate= PostingDate(1);
PostingDate(1)= [];

% Output date (regular)
Date= (ReferenceDate+6:6:PostingDate(end))';

% Spatial size
Size= size(Stack,[1 2]);

% Remove completely empty interferograms
Inan= squeeze(all(isnan(Stack),[1 2]));
if any(Inan)
    PrimaryDate(Inan)= [];
    SecondaryDate(Inan)= [];
    Stack(:,:,Inan)= [];
end

% Flatten
flatStack= reshape(Stack,prod(Size),[])';

% Remove pixels which have any NaNs
Idata= ~any(isnan(flatStack),1);
flatStack= flatStack(:,Idata);




%% Inversion Setup

r_phase= 3.5; % mm
% Numerical phase unwrapping noise. Estimated as the rms of the SBAS
% inversion RMSE, which is 3.42 for grid 36.25,-119.75
% Run miniGridSBAS_dev3, then rms(RMSE(:))

r_trop= 20; % mm
% Tropospheric and other physical noise at each SAR posting. Estimated as
% std of the time-wise difference of the SBAS timeseries, over sqrt(2).
% 19.95 for grid 36.25,-119.75
% Run miniGridSBAS_dev3, then rms(diff(TSflat),'all')/sqrt(2)



Ndate= length(Date);

t= years(Date- ReferenceDate);

% Linear/seasonal trend matrix
A= [t cos(2*pi*t)-1 sin(2*pi*t)];

Bscale= 20; % mm - Covariance scale parameter
tau= 60/365; % yr - Timescale parameter
tt= [0; t];
B= Bscale^2*exp(-(tt-tt').^2/(2*tau^2));
REL= [-1*ones(Ndate,1) eye(Ndate)];
B= REL*B*REL';


% SBAS Matrix
M= utils.designMatrix_linearSplineDisplacement(...
    [PrimaryDate SecondaryDate],[ReferenceDate; PostingDate]);
M= M(:,2:end);

G= double(PostingDate == Date');




%% Bayesian SBAS Inversion

Ninf= height(flatStack);
Npostings= length(PostingDate);

y= flatStack;


% Noise matrices
R_xi= r_trop^2*eye(Npostings); % Tropospheric noise at each posting

R_eta= r_phase^2*eye(Ninf); % Phase noise at each interferogram


% Parameter estimation
M_theta= M*G*A; % Model matrix
R_theta= (M*G)*B*(M*G)'+ M*R_xi*M'+ R_eta; % Noise

P_theta_inv= (M_theta'/R_theta)*M_theta; % Posterior covariance (inverse)
theta_bar= (P_theta_inv\M_theta')*(R_theta\y); % Posterior mean


% Timeseries estimation
mu_x= A*theta_bar; % Prior mean
B_x= (A/P_theta_inv)*A'+ B; % Prior covariance
R_x= M*R_xi*M'+ R_eta; % Noise

K= B_x*(M*G)'/((M*G)*B_x*(M*G)'+ R_x); % Kalman Gain
OptimizerFlat= mu_x+ K*(y- (M*G)*mu_x); % Posterior mean

% Unflatten
DISPtmp= nan([prod(Size) Ndate]);
DISPtmp(Idata,:)= OptimizerFlat';
Optimizer= reshape(DISPtmp,[Size Ndate]);




%% Traditional SBAS Inversion

timeseriesSBASPosting= M\y;

% Interpolate to query times
SBASFlat= interp1([ReferenceDate; PostingDate],[zeros(1,width(y)); timeseriesSBASPosting],Date);

% Unflatten
SBAStmp= nan([prod(Size) Ndate]);
SBAStmp(Idata,:)= SBASFlat';
SBASTimeseries= reshape(SBAStmp,[Size Ndate]);




%% Posterior Covariance

PosteriorCovarianceSqrt= (eye(Ndate)- K*(M*G))*B_x; % Posterior covariance


% The posterior covariance is not necessarily a symmetric-positive-definite
% matrix due to floating-point errors. Instead, the matrix is stored as its
% square root, eliminating the eigenvalues which are complex or to small to
% exceed floating-point precision. 

% Eigenvector decomposition
[V,D]= eig(PosteriorCovarianceSqrt);
d= diag(D);

% Define tolerance as suggested in MATLAB documentation
% https://www.mathworks.com/help/matlab/math/determine-whether-matrix-is-positive-definite.html
% See the section on Numerical Considerations
tolerance= length(d)*eps(max(d));
Itol= d > tolerance;
eigenvectors= real(V(:,Itol));
eigenvalues= real(d(Itol))';

% Square root of the posterior covariance
PosteriorCovarianceSqrt= real(sqrt(eigenvalues).*eigenvectors);

% Note: The full covariance matrix can be reconstructed, to within
% floating-point precision, with the following:
% PosteriorCovariance= PosteriorCovarianceSqrt*PosteriorCovarianceSqrt';



end

