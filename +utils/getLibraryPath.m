%% Library Path

function libraryPath= getLibraryPath()

s= string(split(path,pathsep));

libraryPath= s(endsWith(s,"insar-bayesian-sbas"));

end

