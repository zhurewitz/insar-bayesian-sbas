%% List Directory

function [names,filelist,processingCenter]= listDirectory(datadir)

[names1,filelist1]= io.aria.listDirectory(datadir);
[names2,filelist2]= io.hyp3.listDirectory(datadir);

names= [names1; names2];
filelist= [filelist1; filelist2];

processingCenter= [repmat("ARIA",length(names1),1);...
    repmat("HYP3",length(names2),1)];

end


