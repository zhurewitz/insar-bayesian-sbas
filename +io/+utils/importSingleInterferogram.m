%% Import Single Interferogram

function importSingleInterferogram(h5filename,mission,track,primaryDate,...
    secondaryDate,infLong,infLat,displacementLOS, coherence, connComp,...
    commonGrid,OCEAN,metaGrid,Elevation,inReference,referenceTrendMatrix,...
    commonTrendMatrix,metaTrendMatrix,direction)

trackstr= strcat(mission,'-',string(track));

% Check to see if interferogram has already been processed
path= fullfile('/interferogram/L1-stitched',trackstr);
pDateWritten= h5.read(h5filename,path,'primaryDate');
sDateWritten= h5.read(h5filename,path,'secondaryDate');

if ~isempty(pDateWritten) && any(pDateWritten == primaryDate & sDateWritten == secondaryDate)
    fprintf('Interferogram already written, overwriting. \n')
end


%% Place on Common Grid

[LOS,COH,CON]= io.utils.placeInterferogramOnCommonGrid(commonGrid,...
    infLong,infLat,displacementLOS,coherence,connComp,OCEAN);


%% Detrend Interferogram by Elevation and Reference Area

[LOS,elevationTrend,trendMeta]= ...
    io.utils.detrendInterferogramByElevationAndReferenceArea(...
    LOS,COH,Elevation,metaGrid,inReference,referenceTrendMatrix,...
    commonTrendMatrix,metaTrendMatrix);



%% Save Interferogram to HDF5 ProcessingStore File

io.utils.writeStitchedInterferogram(h5filename,mission,track,primaryDate,...
    secondaryDate,LOS,trendMeta,COH,CON,elevationTrend,direction);

fprintf('Mission %s. Track %d. Interferogram saved.\n',...
    mission, track)


end






