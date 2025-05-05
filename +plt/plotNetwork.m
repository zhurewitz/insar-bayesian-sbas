%% PLT.PLOTNETWORK
% Plots interferogram network

function [h1,c,h2]= plotNetwork(DatePairs,X,Y,Color,LineWidth,LineAlpha,ScatterSize)

arguments
    DatePairs
    X= [];
    Y= [];
    Color= [];
    LineWidth= [];
    LineAlpha= [];
    ScatterSize= 60;
end

if isempty(Color)
    Color= zeros(height(DatePairs),3);
end

if isempty(LineWidth)
    LineWidth= 1;
end

if isempty(LineAlpha)
    LineAlpha= 1;
end

if isempty(X)
    X= unique(DatePairs);
end

if isempty(Y)
    Y= rand(size(X));
end

% Indices
I1= sum(DatePairs(:,1) >= X',2);
I2= sum(DatePairs(:,2) >= X',2);

N= length(I1);

if isdatetime(X)
    lx= [X(I1) X(I2) NaT(N,1)]';
else
    lx= [X(I1) X(I2) nan(N,1)]';
end
lx= lx(:);
ly= [Y(I1) Y(I2) nan(N,1)]';
ly= ly(:);

I= reshape(repmat(1:N,3,1),[],1);

if width(Color) == 3
    C= Color(I,:);
else
    C= Color(I);
end

hold on
hhandle= plt.colorLine(lx',ly',C,LineWidth,LineAlpha);
if ScatterSize > 0
    h2handle= scatter(X,Y,ScatterSize,'k','filled');
end
box on
chandle= colorbar;

if nargout > 0
    h1= hhandle;
end

if nargout > 1
    c= chandle;
end

if nargout > 2
    if ScatterSize > 0
        h2= h2handle;
    else
        h2= [];
    end
end

end