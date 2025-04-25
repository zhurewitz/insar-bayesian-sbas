%% IO.HYP3.STITCHINTERFEROGRAMS

function [LOS,COH,gridLong,gridLat]= stitchInterferograms(frameList,gridLong,gridLat)
%% Input

arguments
    frameList
    gridLong= [];
    gridLat= [];
end

metaData= io.hyp3.shortMetaData(frameList);

if metaData.ProcessingCenter ~= "HYP3"
    error("Frames must be processed by HyP3")
end

if any(metaData.Track ~= metaData.Track(1) | ...
    metaData.PrimaryDate ~= metaData.PrimaryDate(1) | ...
    metaData.SecondaryDate ~= metaData.SecondaryDate(1))
    error("All frames must have the same track, primary date, and secondary date")
end

Nfiles= length(frameList);

% Calculate bounding boxes
boundingBoxes= nan(Nfiles,4);
for i= 1:Nfiles
    boundingBoxes(i,:)= io.hyp3.readBoundingBox(frameList(i));
end

% Remove duplicates (frames with same bounding box)
[~,ia]= unique(round(boundingBoxes/0.01),"rows");
frameList= frameList(ia);
boundingBoxes= boundingBoxes(ia,:);
Nfiles= length(frameList);


% Sort by latitude
[~,ia]= sort(boundingBoxes(:,3));
frameList= frameList(ia);
boundingBoxes= boundingBoxes(ia,:);

% Select output grid
if isempty(gridLong)
    LongLim= [min(boundingBoxes(:,1)) max(boundingBoxes(:,2))];
    LatLim= [min(boundingBoxes(:,3)) max(boundingBoxes(:,4))];

    dL= 1/1200;

    gridLong= (floor(LongLim(1)/dL):ceil(LongLim(2)/dL))*dL;
    gridLat= (floor(LatLim(1)/dL):ceil(LatLim(2)/dL))*dL;
end


%% Stitch

imSize= [length(gridLat) length(gridLong)];
LOS= nan(imSize,'single');
COH= nan(imSize,'single');

for i= 1:Nfiles
    % Read displacement and coherence
    [frameLOS,frameLat,frameLong]= io.hyp3.readLOSDisplacement2(frameList(i));
    frameCOH= io.hyp3.readCoherence(frameList(i));
    
    % Find intersection
    [Iax,Iay,Ibx,Iby]= utils.insertionIndices(gridLong,gridLat,frameLong,frameLat);
    
    % Current values in intersection region
    LOStmp= LOS(Iay,Iax);
    COHtmp= COH(Iay,Iax);
    
    % New values in intersection region
    frameLOStmp= frameLOS(Iby,Ibx);
    frameCOHtmp= frameCOH(Iby,Ibx);
    
    % Correction is mean of difference in overlapping region (with high
    % enough coherence)
    Ioverlap= ~isnan(LOStmp) & ~isnan(frameLOStmp) & COHtmp > 0.5;
    correction= mean(LOStmp(Ioverlap)- frameLOStmp(Ioverlap));
    if isnan(correction)
        correction= 0;
    end
    
    % Replacement pixels
    I= isnan(LOStmp) & ~isnan(frameLOStmp);
    
    % Replace values
    LOStmp(I)= frameLOStmp(I)+ correction; % With correction
    COHtmp(I)= frameCOHtmp(I); 
    
    % Add to stitch
    LOS(Iay,Iax)= LOStmp;
    COH(Iay,Iax)= COHtmp;
end

end