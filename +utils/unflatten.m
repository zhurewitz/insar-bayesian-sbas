%% UTILS.UNFLATTEN
% 
% Input:
%   x - Q x P matrix
%   Size - original 2D size [M N]
%   I - (optional) indices to unflatten
%
% Output:
%   X - M x N x P unflattened stack. Missing pixels are filled with NaNs


function X= unflatten(x,Size,I)

arguments
    x
    Size
    I= [];
end

N= size(x,1);

if isempty(I)
    X= x';
else
    X= nan(prod(Size),N);
    X(I,:)= x';
end

X= reshape(X,[Size N]);

end


