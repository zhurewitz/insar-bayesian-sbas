%% Generate Grid Information

function generateGrid(h5filename,LongLim,LatLim,...
    referenceLongitude,referenceLatitude,studyAreaLongitude,studyAreaLatitude,...
    xorder,yorder)

arguments
    h5filename
    LongLim
    LatLim
    referenceLongitude= [];
    referenceLatitude= [];
    studyAreaLongitude= [];
    studyAreaLatitude= [];
    xorder= 1;
    yorder= 1;
end

savedir= fileparts(h5filename);
if ~exist(savedir,'dir')
    error('Directory %s does not exist',savedir)
end

calculateReference= ~isempty(referenceLongitude);
cropStudyArea= ~isempty(studyAreaLongitude);


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
    inReference= geo.inpolygonfastGrid(commonGrid.Long,commonGrid.Lat,referenceLongitude,referenceLatitude);

    % Detrending matrices
    [LONG,LAT]= meshgrid(single(commonGrid.Long),single(commonGrid.Lat));

    meanLong= mean(commonGrid.Long);
    meanLat= mean(commonGrid.Lat);
    X= LONG- meanLong;
    Y= LAT- meanLat;
    
    [LONGMeta,LATMeta]= meshgrid(metaGrid.Long,metaGrid.Lat);
    Xmeta= LONGMeta- meanLong;
    Ymeta= LATMeta- meanLat;
    
    xr= X(inReference);
    yr= Y(inReference);
    xc= X(:);
    yc= Y(:);
    xm= Xmeta(:);
    ym= Ymeta(:);
    
    referenceTrendMatrix= zeros(length(xr),(yorder+1)*(xorder+1),'single');
    commonGridTrendMatrix= zeros(length(xc),(yorder+1)*(xorder+1),'single');
    metaGridTrendMatrix= zeros(length(xm),(yorder+1)*(xorder+1),'single');
    count= 1;
    for j= 0:yorder
        for i= 0:xorder
            referenceTrendMatrix(:,count)= (xr.^i).*(yr.^j);
            % Usage: p= trendMatrix1\data(IN);
            commonGridTrendMatrix(:,count)= (xc.^i).*(yc.^j);
            % Usage: TREND= reshape(trendMatrix2*p,commonGrid.Size);
            metaGridTrendMatrix(:,count)= (xm.^i).*(ym.^j);
            % Usage: trendMeta= reshape(trendMatrixMeta*p,metaGrid.Size);
            count= count+ 1;
        end
    end
end

if cropStudyArea
    inStudyArea= geo.inpolygonfastGrid(commonGrid.Long,commonGrid.Lat,studyAreaLongitude,studyAreaLatitude);
end



%% Write to HDF5 File

path= '/grid/';
h5.writeGrid(h5filename,path,commonGrid)

if calculateReference
    h5.write(h5filename,path,'referenceMask',uint8(inReference),'Datatype','uint8',...
        'ChunkSize',[600 600],'Deflate',9,'Shuffle',true,'Fletcher32',true)
    if width(referenceTrendMatrix) > 1
        h5.write(h5filename,path,'referenceTrendMatrix',referenceTrendMatrix,'Datatype','single',...
            'ChunkSize',[10000 1],'Deflate',9,'Shuffle',true,'Fletcher32',true)
    else
        h5.write(h5filename,path,'referenceTrendMatrix',referenceTrendMatrix,'Datatype','single',...
        'ChunkSize',10000,'Deflate',9,'Shuffle',true,'Fletcher32',true)
    end
    if width(commonGridTrendMatrix) > 1
        h5.write(h5filename,path,'trendMatrix',commonGridTrendMatrix,'Datatype','single',...
            'ChunkSize',[10000 1],'Deflate',9,'Shuffle',true,'Fletcher32',true)
    else
        h5.write(h5filename,path,'trendMatrix',commonGridTrendMatrix,'Datatype','single',...
            'ChunkSize',10000,'Deflate',9,'Shuffle',true,'Fletcher32',true)
    end
end
if cropStudyArea
    h5.write(h5filename,path,'studyAreaMask',uint8(inStudyArea),'Datatype','uint8',...
        'ChunkSize',[600 600],'Deflate',9,'Shuffle',true,'Fletcher32',true)
end

path= '/metaGrid/';
h5.writeGrid(h5filename,path,metaGrid)

if calculateReference
    h5.write(h5filename,path,'trendMatrix',metaGridTrendMatrix)
end



end








