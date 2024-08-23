%% Parse Input

function [value, found, I]= parseIn(VARARGIN,key)

I= find(strcmpi(string(VARARGIN),key));

found= ~isempty(I);

value= [];
if found && length(VARARGIN) >= I+1
    value= VARARGIN{I+1};
end

end