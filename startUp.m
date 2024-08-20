%% Workflow Start Up Function

function startUp

libraryPath= utils.getLibraryPath;

if isempty(libraryPath)
    error("Path to library not found")
end

matlabProjectDir= string(pwd);


%% Copy Workflow Files

% Step 1
file1= fullfile(libraryPath,"templates","startUserInput.mlx");
copyfile(file1,matlabProjectDir)

% Step 2
file2= fullfile(libraryPath,"templates","referenceAreaWorkflow.mlx");
copyfile(file2,matlabProjectDir)

% Step 3
file3= fullfile(libraryPath,"templates","networkSelectionARIA.mlx");
copyfile(file3,matlabProjectDir)


%% Open Step 1

open(fullfile(matlabProjectDir,"startUserInput.mlx"))


end

