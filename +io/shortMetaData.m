%% Short Meta Data

function metaData= shortMetaData(filelist, processingCenter)

I= strcmpi(processingCenter,"ARIA");
metaData1= io.aria.shortMetaData2(filelist(I));

I= strcmpi(processingCenter,"HYP3");
metaData2= io.hyp3.shortMetaData(filelist(I));

metaData= union(metaData1,metaData2);

end


