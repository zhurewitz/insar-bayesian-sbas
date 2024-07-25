%% Read LOS Displacement

function [LOSdisplacement,frameLat,frameLong,coherence,connComp]= ...
    readLOSdisplacement(filename)

processingCenter= io.determineProcessingCenter(filename);

switch processingCenter
    case "ARIA"
        [LOSdisplacement,frameLat,frameLong,coherence,connComp]= ...
            io.aria.readLOSdisplacement(filename);
    case "HYP3"
        [LOSdisplacement,frameLat,frameLong,correlation]= ...
            io.hyp3.readLOSdisplacement(filename);
        coherence= correlation;
        connComp= [];
    otherwise
        error("File format not recognized")
end

end

