%% Load Stack from HDF5 File

function [Stack,grid,PrimaryDate,SecondaryDate]= loadStack(...
    h5filename,Flag,Mission,Track,PrimaryDate,SecondaryDate,LatLim,LongLim)
%% Input Arguments

arguments
    h5filename
    Flag {mustBeMember(Flag,{"L1","L2"})}
    Mission
    Track
    PrimaryDate= [];
    SecondaryDate= [];
    LatLim= [];
    LongLim= [];
end

if ischar(Mission) || iscellstr(Mission) %#ok<ISCLSTR>
    Mission= string(Mission);
end


% Grid
commonGrid= h5.readGrid(h5filename,'/grid');
dL= commonGrid.dL;
if isempty(LatLim) && isempty(LongLim)
    grid= commonGrid;
else
    if isempty(LatLim)
        LatLim= commonGrid.LatLim;
    else
        LatLim= [max(LatLim(1),commonGrid.LatLim(1)) min(LatLim(2),commonGrid.LatLim(2))];
    end
    if isempty(LongLim)
        LongLim= commonGrid.LongLim;
    else
        LongLim= [max(LongLim(1),commonGrid.LongLim(1)) min(LongLim(2),commonGrid.LongLim(2))];
    end

    grid= utils.createGrid(LatLim,LongLim,dL);
end


% Dates
if isempty(PrimaryDate)
    [PrimaryDate,SecondaryDate]= io.loadDates(h5filename,Flag,Mission,Track);
end

if isempty(PrimaryDate)
    error('No data to load')
end




%% Load

switch Flag
    case "L1"
        basepath= '/interferogram/L1-stitched';
    case "L2"
        basepath= '/interferogram/L2-closureCorrected';
    otherwise
        error('Level flag not supported')
end

trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

[~,iax,~]= intersect(commonGrid.LongLim(1),grid.LongLim(1));
[~,iay,~]= intersect(commonGrid.LatLim(1),grid.LatLim(1));


[PrimaryDateFile,SecondaryDateFile]= io.loadDates(h5filename,Flag,Mission,Track);

% Find indices
k= sum((PrimaryDate == PrimaryDateFile' & SecondaryDate == SecondaryDateFile').*(1:length(PrimaryDateFile)),2);

% Read contiguously if ordered correctly, otherwise read pages individually
if length(k) > 1 && all(diff(k) == diff(k(1:2)))
    start= [iay iax k(1)];
    count= [grid.Size length(k)];
    stride= [1 1 diff(k(1:2))];
    
    Stack= h5read(h5filename,fullfile(path,'data'),start,count,stride);
else
    Npairs= length(PrimaryDate);
    Stack= nan([grid.Size Npairs],'single');
    for i= 1:length(k)
        start= [iay iax k(i)];
        count= [grid.Size 1];
        
        Stack(:,:,i)= h5read(h5filename,fullfile(path,'data'),start,count);
    end
end

end




