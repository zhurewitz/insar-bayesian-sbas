%% List all ARIA-formatted Input Interferograms in Data Directory

function [filelist, fulllist]= listDirectory(datadir)

filelist= split(ls(datadir));
filelist(end)= [];

I= matches(filelist,wildcardPattern+ 'GUNW'+ wildcardPattern+ '.nc');
filelist= sort(filelist(I));

fulllist= fullfile(datadir,filelist);
