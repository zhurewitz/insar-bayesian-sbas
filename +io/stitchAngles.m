%% Stitch Angles

function [inclinationAngle,azimuthAngle,lookVectorX,lookVectorY,lookVectorZ]=...
    stitchAngles(filelist,metaGrid)

metaData= io.shortMetaData(filelist);

processingCenter= unique(metaData.ProcessingCenter);
if length(processingCenter) > 1
    error('Files must be from the same processing center')
end

switch processingCenter
    case "ARIA"
        [inclinationAngle,azimuthAngle,~,lookVectorX,lookVectorY,lookVectorZ]=...
            io.aria.stitchAngles(filelist,metaGrid);
    case "HYP3"
        [inclinationAngle,azimuthAngle,lookVectorX,lookVectorY,lookVectorZ]=...
            io.hyp3.stitchAngles(filelist,metaGrid);
    otherwise
        error('Processing center not recognized')
end

end


