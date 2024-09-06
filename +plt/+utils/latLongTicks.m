%% Ticks in Latitude and Longitude

function latLongTicks(xinc,yinc)

arguments
    xinc= 1;
    yinc= 1;
end

XLIM= xlim;
YLIM= ylim;

xticks(xinc*(floor(XLIM(1)/xinc):ceil(XLIM(2)/xinc)))
Yticks(yinc*(floor(YLIM(1)/yinc):ceil(YLIM(2)/yinc)))

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
