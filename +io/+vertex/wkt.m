%% WKT String

function s= wkt(LongLim,LatLim, printString,copyToClipboard)

arguments
    LongLim 
    LatLim 
    printString= true;
    copyToClipboard= true;
end

S= sprintf("POLYGON((%0.1f %0.1f,%0.1f %0.1f,%0.1f %0.1f,%0.1f %0.1f,%0.1f %0.1f))", ...
    LongLim(1),LatLim(1), LongLim(2),LatLim(1), LongLim(2),LatLim(2),...
    LongLim(1),LatLim(2), LongLim(1),LatLim(1));

if nargout > 0
    s= S;
    return
end

if copyToClipboard
    clipboard("copy",S)
    disp("WKT copied to clipboard")
end

if printString
    disp(S)
end

end
