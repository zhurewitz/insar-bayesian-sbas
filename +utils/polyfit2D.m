%% Polynomial Fit in 2D

function p= polyfit2D(x,y,Z,order)

if isvector(x) && isvector(y)
    [X,Y]= meshgrid(x,y);
else
    X= x;
    Y= y;
end

X= reshape(X,[],1);
Y= reshape(Y,[],1);

I= ~isnan(Z(:));

X= X(I);
Y= Y(I);
Z= Z(I);
N= sum(I);

A= zeros(N,.5*(order+1)*(order+2));
k= 0;
for i= 0:order
    for j= 0:order-i
        k= k+1;
        
        A(:,k)= X.^i.*Y.^j;
    end
end

p= (A'*A)\(A'*Z(:));

end






