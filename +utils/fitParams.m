%% FITPARAMS
% Least-squares fit of data to a parameter matrix. Removes missing data. In
% the case of repeated columns of ones or zeros, they are removed from the
% parameter fit, and the corresponding parameters are forced to zero.
%
% Input
%   X - (Nt x Nx) Data matrix. If a timeseries, X(:,i) is the timeseries
%   for the i-th point.
%   ParameterMatrix - (Nt x Nparams) parameter matrix
% Output:
%   Params - (Nparams x Nt) Matrix of interpreted parameters. Params(:,i)
%   is the set of parameters for the i-th point.
%   BestFit - (Nt x Nx) Optimal parameter fit
%   Residual - (Nt x Nx) Difference between X and BestFit
%   RMSE - (1 x Nx) Root-mean square error
%   Covariance - (Nparams x Nparams) Optional L-S covariance matrix
% 
% For example, if wishing to fit to the function y(t)= a+ b*t+ c*t^2, the
% parameter matrix would be the following:
% [1 t0 t0^2 
%  1 t1 t1^2 
%  1 t2 t2^2 
%    ...    ]
%
% And the Params output would be 
% [ a0 a1 a2 
%   b0 b1 b2 ...
%   c0 c1 c2 ]


function [Params,BestFit,Residual,RMSE,Covariance]= fitParams(X,ParameterMatrix)

Nparams= width(ParameterMatrix);
Nx= width(X);

Params= zeros(Nparams,Nx);

for i= 1:Nx
    J= ~isnan(X(:,i));
    Atmp= ParameterMatrix(J,:);
    
    % Remove all columns of zeros and columns of ones which would make the
    % matrix singular. Those parameters will be forced to be zero
    Izero= all(Atmp == 0);
    Ione= all(Atmp == 1);
    Ikeep= ~Izero & ~Ione;
    
    Ifirst= find(Ione,1); % However, if there are multiple columns of ones, keep the first
    Ikeep(Ifirst)= true;
    
    A= Atmp(:,Ikeep);
    
    y= X(J,i);
    
    % Solve normal equations (Note: change to lsqr?)
    p= (A'*A)\(A'*y);
    
    Params(Ikeep,i)= p;
end

BestFit= ParameterMatrix*Params;
Residual= X- BestFit;
RMSE= rms(Residual,'omitmissing');

if nargout > 4
    Covariance= inv(A'*A);
end

end