%% Generate Grid Information

function generateGrid(h5filename,LongLim,LatLim,...
    referenceLongitude,referenceLatitude)

arguments
    h5filename
    LongLim
    LatLim
    referenceLongitude= [];
    referenceLatitude= [];
end

savedir= fileparts(h5filename);
if ~exist(savedir,'dir')
    error('Directory %s does not exist',savedir)
end

calculateReference= ~isempty(referenceLongitude);


% Native interferogram grid increment
dL= 1/1200; % degrees

% Make commonGrid struct
commonGrid= utils.createGrid(LatLim,LongLim,dL);

% Metadata grid needs to be large enough to cover commonGrid completely
dLmeta= .1;
metaLatLim= [floor(LatLim(1)/dLmeta)*dLmeta ceil(LatLim(2)/dLmeta)*dLmeta];
metaLongLim= [floor(LongLim(1)/dLmeta)*dLmeta ceil(LongLim(2)/dLmeta)*dLmeta];
metaGrid= utils.createGrid(metaLatLim,metaLongLim,dLmeta,true);



%% Detrending Matrices

if calculateReference
    IN= geo.inpolygonfastGrid(commonGrid.Long,commonGrid.Lat,referenceLongitude,referenceLatitude);

    % Detrending matrices
    [LONG,LAT]= meshgrid(single(commonGrid.Long),single(commonGrid.Lat));

    meanLong= mean(commonGrid.Long);
    meanLat= mean(commonGrid.Lat);
    X= LONG- meanLong;
    Y= LAT- meanLat;
    xref= X(IN);
    yref= Y(IN);

    referenceTrendMatrix= [ones(size(xref),'single') xref yref];
    % Usage: p= trendMatrix1\data(IN);

    commonGridTrendMatrix= [ones(numel(X),1,'single') X(:) Y(:)];
    % Usage: TREND= reshape(trendMatrix2*p,commonGrid.Size);


    [LONGMeta,LATMeta]= meshgrid(metaGrid.Long,metaGrid.Lat);
    Xmeta= LONGMeta- meanLong;
    Ymeta= LATMeta- meanLat;

    metaGridTrendMatrix= [ones(numel(Xmeta),1,'single') Xmeta(:) Ymeta(:)];
    % Usage: trendMeta= reshape(trendMatrixMeta*p,metaGrid.Size);

end



%% Write to HDF5 File

path= '/grid/';
h5.writeGrid(h5filename,path,commonGrid)

if calculateReference
    h5.write(h5filename,path,'referenceMask',uint8(IN),'Datatype','uint8',...
        'ChunkSize',[600 600],'Deflate',9,'Shuffle',true,'Fletcher32',true)
    h5.write(h5filename,path,'referenceTrendMatrix',referenceTrendMatrix,'Datatype','single',...
        'ChunkSize',[10000 1],'Deflate',9,'Shuffle',true,'Fletcher32',true)
    h5.write(h5filename,path,'trendMatrix',commonGridTrendMatrix,'Datatype','single',...
        'ChunkSize',[10000 1],'Deflate',9,'Shuffle',true,'Fletcher32',true)
end

path= '/metaGrid/';
h5.writeGrid(h5filename,path,metaGrid)

if calculateReference
    h5.write(h5filename,path,'trendMatrix',metaGridTrendMatrix)
end



end








