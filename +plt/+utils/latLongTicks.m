%% Ticks in Latitude and Longitude

function latLongTicks(xinc,yinc)

arguments
    xinc= [];
    yinc= [];
end

XLIM= xlim;
YLIM= ylim;

if isempty(xinc)
    xinc= tickIncrement(diff(xlim));
end

if isempty(yinc)
    yinc= tickIncrement(diff(ylim));
end


xticks(xinc*(floor(XLIM(1)/xinc):ceil(XLIM(2)/xinc)))
yticks(yinc*(floor(YLIM(1)/yinc):ceil(YLIM(2)/yinc)))

XTICKS= xticks;
XTICKLABELS= "";
for i= 1:length(XTICKS)
    if sign(XTICKS(i)) < 0; dir= 'W'; else; dir= 'E'; end
    XTICKLABELS(i)= strcat(string(abs(XTICKS(i))),char(176),dir);
end
YTICKS= yticks;
YTICKLABELS= "";
for i= 1:length(YTICKS)
    if sign(YTICKS(i)) < 0; dir= 'S'; else; dir= 'N'; end
    YTICKLABELS(i)= strcat(string(abs(YTICKS(i))),char(176),dir);
end
xticklabels(XTICKLABELS)
yticklabels(YTICKLABELS)

end


function inc= tickIncrement(n)

b= 10^floor(log10(n));
a= n/b;

if a < 1.5
    ainc= .25;
elseif a < 3
    ainc= .5;
elseif a <= 5
    ainc= 1;
elseif a <= 8
    ainc= 2;
else
    ainc= 2.5;
end

inc= ainc*b;

end