%% List Directory

function [filelist,fulllist]= listDirectory(datadir)

dirlist= string(split(ls(datadir)));

I= contains(dirlist,'S1'+ characterListPattern('AB')+ characterListPattern('AB')+'_')...
    & ~contains(dirlist,'.zip');

filelist= dirlist(I);

fulllist= fullfile(datadir,filelist);

end
