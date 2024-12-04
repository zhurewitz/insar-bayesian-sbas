%% UNR GPS Station Timeseries
% Download station timeseries from UNR NGL
% No correction or processing is done in this function.
% 
% Input
%   ID: 4-character station ID (e.g "ZLA1")
% Output
%   Date (N x 1 datetime vector)
%   Displacement (N x 3 array): East-North-Up timeseries of displacement in
%       millimeters
%   Covariance (optional N x 6 array): Timeseries of formal uncertainties
%       from the GNSS processing expressed as the covariance matrix. Units 
%       are millimeters^2. Format is [Cxx Cyy Czz Cxy Cxz Cyz]. Covariance
%       matrices are symmetrical. The covariance for the i-th timestep
%       could be constructed as below, where C= Covariance
%           [C(i,1) C(i,4) C(i,5)
%            C(i,4) C(i,2) C(i,6)
%            C(i,5) C(i,6) C(i,3)]
% 
% Details at: http://geodesy.unr.edu/PlugNPlayPortal.php
% Citation: Blewitt 2018. https://doi.org/10.1029/2018EO104623
% Full citation at above link or DOI

function [Date, Displacement, Covariance]= downloadUNRTimeseries(ID)

filename= strcat("http://geodesy.unr.edu/gps_timeseries/tenv3/IGS14/", ID, ".tenv3");

T= readtable(filename,"FileType","text",'VariableNamingRule','preserve');

Date= datetime(T.YYMMMDD,'InputFormat','yyMMMdd');

EAST= T.("__east(m)")*1000; % mm
NORTH= T.("_north(m)")*1000; % mm
UP= T.("____up(m)")*1000; % mm

Displacement= [EAST NORTH UP]; % mm

if nargout >= 3
    % Standard deviations - Units meters
    sx= T.("sig_e(m)");
    sy= T.("sig_n(m)");
    sz= T.("sig_u(m)");
    
    % Pearson correlation coefficients - unitless
    % https://en.wikipedia.org/wiki/Pearson_correlation_coefficient#For_a_population
    pxy= T.("__corr_en");
    pxz= T.("__corr_eu");
    pyz= T.("__corr_nu");

    % Covariance matrix [Cxx Cyy Czz Cxy Cxz Cyz] - Units mm^2
    Covariance= [sx.^2 sy.^2 sz.^2 pxy.*sx.*sy pxz.*sx.*sz pyz.*sy.*sz]*1000^2;
end

end
