%% Stitch Interferograms

function [infLong,infLat,interferogram,coherence,connComp,missingMask,errorFlag]=...
    stitchInterferograms(filelist,infLong,infLat,inStudyArea)

arguments
    filelist
    infLong= [];
    infLat= [];
    inStudyArea= [];
end

errorFlag= 0;

Crop= ~isempty(inStudyArea);

filelist= string(filelist);

Nframes= length(filelist);

% Load metadata
frameTable= table;
for i= 1:Nframes
    frameTable(i,:)= io.shortMetaData(filelist(i));
    
    Mission= string(frameTable.Mission);
    
    % Check processing center, mission, track, and primary and secondary date compatibility
    if i > 1
        if any(~strcmpi(frameTable.ProcessingCenter(1:i-1),frameTable.ProcessingCenter(i)))
            error('To stitch interferograms, all frames must be processed by the same processing center')
        end
        if any(~strcmpi(Mission(1:i-1),Mission(i)) | frameTable.Track(1:i-1) ~= frameTable.Track(i))
            error('To stitch interferograms, all frames must be from the same mission and track')
        end
        if any(frameTable.PrimaryDate(1:i-1) ~= frameTable.PrimaryDate(i) | frameTable.SecondaryDate(1:i-1) ~= frameTable.SecondaryDate(i))
            error('To stitch interferograms, all frames must have the same primary and secondary dates')
        end
    end
end


% Read bounding boxes
boundingBoxes= nan(Nframes,4);
for i= 1:Nframes
    boundingBoxes(i,:)= io.readBoundingBox(filelist(i));
end

% Sort interferograms going upwards in latitude
[~,I]= sort(boundingBoxes(:,3));
frameTable= frameTable(I,:);

if isempty(infLong)
    dL= 1/1200;
    
    % Image bounding box (union of all frame bounding boxes)
    boundingBox= [-1 1 -1 1].*max(boundingBoxes.*[-1 1 -1 1],[],1);
    boundingBox = boundingBox + .1*[-1 1 -1 1]; % Bug fix for hyp3 misalignment

    infLong= boundingBox(1):dL:boundingBox(2)+dL;
    infLat= boundingBox(3):dL:boundingBox(4)+dL;
else
    dL= abs(diff(infLong(1:2)));
end

imSize= [length(infLat) length(infLong)];

interferogram= nan(imSize,'single');
coherence= nan(imSize,'single');
connComp= [];
missingMask= false(imSize);

[LONG,~]= meshgrid(infLong,infLat);


for j= 1:Nframes
    filename= frameTable.Fullname(j);
    
    % Read interferogram
    [frameLOS,frameLat,frameLong,frameCoherence,frameConnComp]=...
        io.readLOSdisplacement(filename);
    
    [Ilong,Ilat]= insertionIndices(infLong,infLat,frameLong,frameLat,dL);

    tmpLOS= nan(imSize,'single');
    tmpCOH= nan(imSize,'single');
    if ~isempty(frameConnComp)
        tmpConn= nan(imSize,'single');
    else
        tmpConn= [];
    end
    tmpMask= false(imSize);

    tmpLOS(Ilat,Ilong)= frameLOS;
    tmpCOH(Ilat,Ilong)= frameCoherence;
    if ~isempty(frameConnComp)
        tmpConn(Ilat,Ilong)= frameConnComp;
    end
    tmpMask(Ilat,Ilong)= ~isnan(frameLOS);
    
    if Crop
        tmpLOS(~inStudyArea)= nan;
        tmpCOH(~inStudyArea)= nan;
        if ~isempty(tmpConn)
            tmpConn(~inStudyArea)= nan;
        end
        tmpMask(~inStudyArea)= false;
    end
    
    % Mask overlap region by coherence value (poor coherence regions
    % introduce stitching errors)
    OVERLAP= missingMask & tmpMask & tmpCOH > .7;
    
    correction= zeros(imSize);
    if any(OVERLAP,'all')
        X= LONG(OVERLAP);
        Y= tmpLOS(OVERLAP)- interferogram(OVERLAP);
        
        p= polyfit(X,Y,1);
        correction= -polyval(p,LONG);
    else
        if j > 1
            errorFlag= 1;
            warning('No coherent overlap found when stitching file %s',filelist(i))
            correction= -mean(tmpLOS,'all','omitmissing')+ ...
                mean(interferogram,'all','omitmissing')+ zeros(imSize,'single');
        end
    end

    interferogram(tmpMask)= tmpLOS(tmpMask)+ correction(tmpMask);
    coherence(tmpMask)= tmpCOH(tmpMask);
    if ~isempty(tmpConn)
        if isempty(connComp)
            connComp= false(imSize);
        end
        connComp(tmpMask)= connComp(tmpMask) | tmpConn(tmpMask); %#ok<AGROW>
    end
    missingMask= missingMask | tmpMask;
end

end





function [Ix,Iy]= insertionIndices(gridLong,gridLat,inLong,inLat,dL)

IXstart= round((min(inLong)- min(gridLong))/dL);
IYstart= round((min(inLat)- min(gridLat))/dL);

Ix= IXstart+ (1:length(inLong));
Iy= IYstart+ (1:length(inLat));

end