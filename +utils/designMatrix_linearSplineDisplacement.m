%% Linear Spline - Displacement Space

% Design Matrix for Linear Spline Fit
% - Apply known interferogram displacements (D size Nt-1 x 1) at each
%       segment of the linear spline to get spline displacement, or
% - Invert known interferogram displacements to get displacement of each
%       line segment (may require a regularization matrix)
% - Inputs: 
%       T - (size NTx2) start T(:,1) and end time T(:,2) for each
%           interferogram measurement
%       t - (size Ntx1) Nodes of the linear spline 
% - Output size: NT x Nt-1
% - Use: d= M*D or D= M\d

function M= designMatrix_linearSplineDisplacement(T,t)

if size(T,2) ~= 2
    error('Input T is not of size Nx2')
end
if ~issorted(t)
    error('Input t is not sorted')
end
if any(T(:,1) > T(:,2))
    error('T is not sorted in the 2nd dimension')
end

if any(T(:,1) < t(1)) || any(T(:,2) > t(end))
    error('T falls outside of the range defined by t')
end

t= reshape(t,1,[]);
NT= size(T,1);
M= zeros(NT,length(t));

for j= 1:NT
    for i= 1:2
        x= T(j,i);
        if any(x == t)
            M(j,:)= M(j,:)+ (x == t)*(-1)^i;
        else
            I= find(t >= x,1)- 1;
            m= abs(x- t(I+ [1 0]));
            m= m/sum(m)*(-1)^i;
            M(j,I+ [0 1])= M(j,I+ [0 1])+ m;
        end
    end
end

% M= sparse(M);

end