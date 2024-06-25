%% Read Bounding Box

function boundingBox= readBoundingBox(filename)

processingCenter= io.determineProcessingCenter(filename);

switch processingCenter
    case "ARIA"
        boundingBox= io.aria.readBoundingBox(filename);
    case "HYP3"
        boundingBox= io.hyp3.readBoundingBox(filename);
    otherwise
        boundingBox= [];
end

end


