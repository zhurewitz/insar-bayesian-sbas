%% Write L1 Stitched Interferogram to H5 Processing File

function writeStitchedInterferogram(L1filename,Mission,Track,PrimaryDate,...
    SecondaryDate,LOS,trendMeta,COH,CON,elevationTrend,direction)

basename= '/interferogram/L1-stitched/';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basename,trackstr);

[PRIMARYDATE,SECONDARYDATE]= io.loadDates(L1filename,'L1',Mission,Track);

if isempty(PRIMARYDATE)
    k= 1;
else
    % Find where to place data if location already exists
    I= PrimaryDate == PRIMARYDATE & SecondaryDate == SECONDARYDATE;
    if any(I)
        if sum(I) > 1
            error('Data for this date pair somehow exists multiple times already')
        end
        k= find(I,1);
    else
        k= length(PRIMARYDATE)+ 1;
    end
end

% Write to file
h5.write2DInf(L1filename,path,'data',LOS,k,[300 300 1],3)
h5.writeatts(L1filename,path,'data','units','mm','direction','LOS','orientation','upwards')

if strcmpi(direction,"A") || strcmpi(direction,"Ascending")
    direction= "ascending";
elseif strcmpi(direction,"D") || strcmpi(direction,"Descending")
    direction= "descending";
end
h5.writeatts(L1filename,path,'','mission',Mission,'track',Track,'direction',direction)

h5.writeScalar(L1filename,path,'primaryDate',PrimaryDate,Inf,k)
h5.writeScalar(L1filename,path,'secondaryDate',SecondaryDate,Inf,k)
h5.writeScalar(L1filename,path,'temporalBaseline',days(SecondaryDate-PrimaryDate),Inf,k)
h5.writeatts(L1filename,path,'temporalBaseline','units','days')

h5.write2DInf(L1filename,path,'trendMeta',trendMeta,k,[size(trendMeta) 1])
h5.writeatts(L1filename,path,'trendMeta','units','mm')

% Write coherence and connComp
h5.write2DInf(L1filename,path,'coherence',COH,k,[300 300 1],3)
if ~isempty(CON)
    h5.write2DInf(L1filename,path,'connComp',CON,k,[300 300 1],3)
end

h5.writeScalar(L1filename,path,'elevationTrend',elevationTrend,Inf,k)
h5.writeatts(L1filename,path,'elevationTrend','units','mm/m')

end