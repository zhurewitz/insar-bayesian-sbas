%% Polynomial Fit in 2D

function Z= polyval2D(p,x,y)

% Invert order from triangular number formula + quadratic formula where the
% triangular number is the length of the polynomial parameter vector
order= round(-1.5+ .5*sqrt(8*length(p)+1));


SIZE= [length(y) length(x)];
N= prod(SIZE);

[X,Y]= meshgrid(x,y);
X= reshape(X,1,1,N);
Y= reshape(Y,1,1,N);

A= zeros(N,length(p));
k= 0;
for i= 0:order
    for j= 0:order-i
        k= k+1;
        
        A(:,k)= X.^i.*Y.^j;
    end
end

Z= reshape(A*p,SIZE);

end






