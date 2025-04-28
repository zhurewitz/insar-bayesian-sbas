%% IO.VERTEX.downloadSLCMetaData
% Downloads SLC metadata given a track and bounding box using ASF Search
% API

function filename= downloadSLCMetaData(Track,LongLim,LatLim,outputFilename)

arguments
    Track 
    LongLim 
    LatLim 
    outputFilename= [];
end

if isempty(outputFilename) || outputFilename == ""
    outputFilename= strcat("SLC",string(datetime("now"),"yyyy-MM-dd HH:mm:ss"),".geojson");
end


baseString= "https://api.daac.asf.alaska.edu/services/search/param?dataset=SENTINEL-1";
intersectsWithString= sprintf("intersectsWith=%s",io.vertex.wkt(LongLim,LatLim));
trackString= sprintf("relativeOrbit=%d",Track);
processingString= "processinglevel=SLC";
maxResultsString= "maxResults=5000";
outputString= "output=GEOJSON";

Strings= [baseString
    intersectsWithString
    trackString
    processingString
    maxResultsString
    outputString];

URL= join(Strings,"&");

outputFilename= websave(outputFilename,URL);

if nargout > 0
    filename= outputFilename;
end

end



