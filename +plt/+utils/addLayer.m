%% Add Transparent Layer 

function C= addLayer(C1,C2,Alpha)

arguments
    C1
    C2
    Alpha= [];
end

if all(size(C1,[1 2]) == [1 1])
    C1= repmat(C1,size(C2,1),size(C2,2));
end

if size(C1,3) == 1 & size(C2,3) == 3
    C1= repmat(C1,1,1,3);
elseif size(C1,3) == 3 & size(C2,3) == 1
    C2= repmat(C2,1,1,3);
end

Inan1= isnan(C1);
Inan2= isnan(C2);

C= nan(size(C1));

I= Inan1 & ~Inan2;
C(I)= C2(I);

I= ~Inan1 & Inan2;
C(I)= C1(I);

I= ~Inan1 & ~Inan2;
if ~isempty(Alpha)
C(I)= C1(I)*(1-Alpha)+ C2(I)*Alpha;
else
    C(I)= C2(I);
end

end