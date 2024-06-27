%% Read LOS Displacement

function [LOSdisplacement,frameLat,frameLong]= ...
    readLOSdisplacement(filename)

processingCenter= io.determineProcessingCenter(filename);

switch processingCenter
    case "ARIA"
        [LOSdisplacement,frameLat,frameLong]= ...
            io.aria.readLOSdisplacement(filename);
    case "HYP3"
        [LOSdisplacement,frameLat,frameLong]= ...
            io.hyp3.readLOSdisplacement(filename);
    otherwise
        error("File format not recognized")
end

end

