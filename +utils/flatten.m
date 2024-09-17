%% UTILS.FLATTEN
% Flattens a 3D matrix (for example a stack of images) to a 2D matrix
%
% Inputs:
%   X - M x N x P matrix
%   method
%       "any" - (default) If there is any NaN value, the entire pixel is removed
%       "all" - The pixel is only removed if all the values are NaN
%       "none"- No pixels are removed
%
% Outputs:
%   x - P x Q matrix where Q <= M*N
%   Size - original 2D size [M x N]
%   I - logical array of indices which were removed

function [x,Size,I]= flatten(X,method)

arguments
    X
    method {mustBeMember(method,["any" "all" "none"])}= "any";
end

if nargout < 3
    method= "none";
end


Size= size(X,[1 2]);

x= reshape(X,prod(Size),[]);

switch method
    case "any"
        I= ~any(isnan(x),2);
    case "all"
        I= ~all(isnan(x),2);
    case "none"
        I= true(prod(Size),1);
end

x= x(I,:)';

end