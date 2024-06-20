%% Area of Interest Workflow

% *** Begin User Input ***

southBound= 35;
northBound= 36;
westBound= -119.3;
eastBound= -117.5;

% *** End User Input ***



%% Write string and copy to clipboard

S= sprintf('POLYGON((%g,%g %g,%g %g,%g %g,%g %g,%g))',...
    westBound,southBound,eastBound,southBound,...
    eastBound,northBound,westBound,northBound,...
    westBound,southBound);

disp(S)

clipboard("copy",S)





