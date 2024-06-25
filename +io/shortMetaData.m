%% Short Meta Data

function metaData= shortMetaData(filelist, processingCenter)

arguments
    filelist
    processingCenter= [];
end

if isempty(processingCenter)
    processingCenter= io.determineProcessingCenter(filelist);
end

I= strcmpi(processingCenter,"ARIA");
metaData1= io.aria.shortMetaData2(filelist(I));

I= strcmpi(processingCenter,"HYP3");
metaData2= io.hyp3.shortMetaData(filelist(I));

if isempty(metaData1)
    metaData= metaData2;
elseif isempty(metaData2)
    metaData= metaData1;
else
    metaData= union(metaData1,metaData2);
end

end


