%% Unique Regions
% Splits an array into regions from Istart(i):Iend(i), where the array
% value in that section is Value(i)
% 
% Empty arrays, logical arrays, and arrays with a single value all work
% fine
%
% Numerical Example: uniqueRegions([1 3 3 3 2 2 3 3])
% Output: Istart= [1 2 5 7]; Iend= [1 4 6 8]; Value= [1 3 2 3];
%
% Logical Example: uniqueRegions([0 0 0 1 1 0 1 1 1 1])
% Output: Istart= [1 4 6 7]; Iend= [3 5 6 10]; Value= [0 1 0 1];

function [Istart, Iend, Value]= uniqueRegions(A)

arguments
    A (1,:) 
end

F= find(diff(A));

Istart= [1 max(F+1,1)];
Iend= [min(F,length(A)) length(A)];

Igood= Iend >= Istart;
Istart= Istart(Igood);
Iend= Iend(Igood);

Value= A(Istart);

end
