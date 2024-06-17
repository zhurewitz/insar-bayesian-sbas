%% Write L1 Stitched Interferogram to H5 Processing File

function writeStitchedInterferogram(L1filename,Mission,Track,PrimaryDate,...
    SecondaryDate,LOS,trendMeta)

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

h5.writeatts(L1filename,path,'','mission',Mission,'track',Track,'direction','PLACEHOLDER')

h5.writeScalar(L1filename,path,'primaryDate',PrimaryDate,Inf,k)
h5.writeScalar(L1filename,path,'secondaryDate',SecondaryDate,Inf,k)

h5.write2DInf(L1filename,path,'trendMeta',trendMeta,k,[size(trendMeta) 1])
h5.writeatts(L1filename,path,'trendMeta','units','mm')


end