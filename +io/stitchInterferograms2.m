%% Stitch Interferograms

function [infLong,infLat,interferogram,coherence,mask,metaData]=...
    stitchInterferograms2(filelist)

filelist= string(filelist);

Nframes= length(filelist);

% Load metadata
frameTable= table;
for i= 1:Nframes
    frameTable(i,:)= io.aria.readMetaData(filelist(i));
    
    Mission= string(frameTable.Mission);
    
    % Check mission, track, and primary and secondary date compatibility
    if i > 1
        % frameTable.Mission(1:i-1)
        % ~strcmpi(frameTable.Mission(1:i-1),frameTable.Mission(i))
        % frameTable.Track(1:i-1)
        % frameTable.Track(1:i-1) ~= frameTable.Track(i)
        if any(~strcmpi(Mission(1:i-1),Mission(i)) | frameTable.Track(1:i-1) ~= frameTable.Track(i))
            error('To stitch interferograms, all frames must be from the same mission and track')
        end
        if any(frameTable.PrimaryDate(1:i-1) ~= frameTable.PrimaryDate(i) | frameTable.SecondaryDate(1:i-1) ~= frameTable.SecondaryDate(i))
            error('To stitch interferograms, all frames must have the same primary and secondary dates')
        end
    end
end



% Sort interferograms going upwards in latitude
[~,I]= sort(frameTable.BoundingBox(:,3));
frameTable= frameTable(I,:);

% Image bounding box (union of all frame bounding boxes)
boundingBox= [-1 1 -1 1].*max(frameTable.BoundingBox.*[-1 1 -1 1],[],1);

dL= 1/1200;

infLong= boundingBox(1):dL:boundingBox(2)+dL;
infLat= boundingBox(3):dL:boundingBox(4)+dL;
imSize= [length(infLat) length(infLong)];

interferogram= nan(imSize,'single');
coherence= nan(imSize,'single');
mask= false(imSize);

[LONG,~]= meshgrid(infLong,infLat);


for j= 1:Nframes
    filename= frameTable.Fullname(j);
    
    % Read interferogram
    [frameLOS,frameLat,frameLong,~,~,frameCoherence,~]=...
        io.aria.readLOSdisplacement(filename);
    
    [Ilong,Ilat]= insertionIndices(infLong,infLat,frameLong,frameLat,dL);

    tmpLOS= nan(imSize,'single');
    tmpCoherence= nan(imSize,'single');
    tmpMask= false(imSize);

    tmpLOS(Ilat,Ilong)= flip(frameLOS);
    tmpCoherence(Ilat,Ilong)= flip(frameCoherence);
    tmpMask(Ilat,Ilong)= flip(~isnan(frameLOS));

    OVERLAP= mask & tmpMask & tmpCoherence > 0.9;
    
    correction= zeros(imSize);
    if any(OVERLAP,'all')
        X= LONG(OVERLAP);
        Y= tmpLOS(OVERLAP)- interferogram(OVERLAP);
        
        p= polyfit(X,Y,1);
        correction= -polyval(p,LONG);
    else
        if j > 1
            warning('No coherent overlap found when stitching file %s, no correction applied',filelist(i))
        end
    end

    interferogram(tmpMask)= tmpLOS(tmpMask)+ correction(tmpMask);
    coherence(tmpMask)= tmpCoherence(tmpMask);
    mask= mask | tmpMask;
end

metaData= utils.keepTableVariables(frameTable(1,:),{'Mission','Band',...
    'Track','Direction','PrimaryDate','SecondaryDate','TemporalBaseline',...
    'SpatialBaseline','Wavelength_mm'});
metaData.Direction= metaData.Direction(:,1); % Convert direction to short form (A/D)
metaData.BoundingBox= boundingBox;

end





function [Ix,Iy]= insertionIndices(gridLong,gridLat,inLong,inLat,dL)

IXstart= round((min(inLong)- min(gridLong))/dL);
IYstart= round((min(inLat)- min(gridLat))/dL);

Ix= IXstart+ (1:length(inLong));
Iy= IYstart+ (1:length(inLat));

end