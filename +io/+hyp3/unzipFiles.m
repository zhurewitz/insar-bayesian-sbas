%% Unzip HyP3 Interferogram Files

function unzipFiles(datadir, zipdir)

arguments
    datadir= [];
    zipdir= [];
end

if isempty(datadir) || datadir == ""
    datadir= string(pwd);
end

if isempty(zipdir) || zipdir == ""
    zipdir= fullfile(datadir,"ZIPs");
end

% List directory
dirlist= string(split(ls(datadir),newline));

% Extract .zip files
I= contains(dirlist,'S1'+ characterListPattern('AB')+ characterListPattern('AB')+'_')...
    & contains(dirlist,'.zip');
ziplist= dirlist(I);


%% Unzip

Nfiles= length(ziplist);
for i= 1:Nfiles
    zipfile= fullfile(datadir,ziplist(i));
    [~,name]= fileparts(zipfile);
    
    dirname= fullfile(datadir,name);
    
    if exist(dirname,'dir')
        fprintf("Interferogram %d/%d already unzipped \n",i,Nfiles)
        moveToZIPDir(zipfile,zipdir)
    else
        fprintf("Unzipping interferogram %d/%d\n",i,Nfiles)
        unzip(zipfile,datadir)
        moveToZIPDir(zipfile,zipdir)
    end
end

end



%% Wrapper for movefile

function moveToZIPDir(zipfile,zipdir)

if ~exist(zipdir,'dir')
    try
        mkdir(zipdir)
    catch ME
        warning("Could not create ZIPs directory, ZIP file will be left in place")
    end
end

if exist(zipdir,'dir')
    try
        movefile(zipfile,zipdir)
    catch ME
        
    end
end

end



