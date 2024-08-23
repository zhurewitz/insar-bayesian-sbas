%% UTILS.GETH5PATH

function path= getH5Path(Flag, Mission, Track)

arguments
    Flag {mustBeMember(Flag,{'L1','L2','L3'})}
    Mission {mustBeMember(Mission,{'S1','NISAR'})}
    Track 
end

switch Flag
    case "L1"
        basepath= fullfile("/interferogram/L1-stitched");
    case "L2"
        basepath= fullfile("/interferogram/L2-closureCorrected");
    case "L3"
        basepath= fullfile("/timeseries/L3-displacement");
end

trackstr= strcat(Mission,"-",string(Track));
path= fullfile(basepath,trackstr);

end

