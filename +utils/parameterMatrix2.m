%% ParameterMatrix

function [A, t, tEQ, tYear, referenceDate, postSeismicTimescale]= ...
    parameterMatrix2(Date,...
    Coseismic,Velocity,Postseismic,Annual,Semiannual,...
    referenceDate,postSeismicTimescale)

arguments
    Date
    Coseismic= true;
    Velocity= true;
    Postseismic= false;
    Annual= false;
    Semiannual= false;
    referenceDate= [];
    postSeismicTimescale= [];
end

if isempty(referenceDate)
    referenceDate= datetime(2015,1,1);
end

if isempty(postSeismicTimescale)
    postSeismicTimescale= 0.5;
end


Nt= length(Date);

% Years since reference date
t= years(Date-referenceDate);

% Years since earthquake
DateEQ= datetime(2019,7,6);
tEQ= years(Date- DateEQ);

% Years since Jan 1st of reference year
tYear= years(Date-datetime(year(Date(1)),1,1));

% Heaviside step function at EQ date
H= tEQ >= 0;

% Post-seismic function
p= H.*(1- exp(-tEQ/postSeismicTimescale));

% Parameter matrix
A= ones(Nt,1);

if Velocity
    A= [t A];
end

if Coseismic
    A= [A H];
end

if Postseismic
    A= [A p];
end

if Annual
    A= [A cos(2*pi*tYear) sin(2*pi*tYear)];
end

if Semiannual
    A= [A cos(4*pi*tYear) sin(4*pi*tYear)];
end

end

