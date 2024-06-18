%% Load MiniGrid Stack

function [Stack,grid,PrimaryDate,SecondaryDate]= loadL1Stack(...
    L1filename,Mission,Track,PrimaryDate,SecondaryDate,LatLim,LongLim)
%% Input Arguments

arguments
    L1filename
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
commonGrid= h5.readGrid(L1filename,'/grid');
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
    [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
end

if isempty(PrimaryDate)
    error('No data to load')
end




%% Load

basepath= '/interferogram/L1-stitched';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

[~,iax,~]= intersect(commonGrid.LongLim(1),grid.LongLim(1));
[~,iay,~]= intersect(commonGrid.LatLim(1),grid.LatLim(1));


[PrimaryDateFile,SecondaryDateFile]= io.loadDates(L1filename,'L1',Mission,Track);

k= sum((PrimaryDate == PrimaryDateFile' & SecondaryDate == SecondaryDateFile').*(1:length(PrimaryDateFile)),2);

% Read contiguously if ordered correctly, otherwise read pages individually
if length(k) > 1 && all(diff(k) == diff(k(1:2)))
    start= [iay iax k(1)];
    count= [grid.Size length(k)];
    stride= [1 1 diff(k(1:2))];
    
    Stack= h5read(L1filename,fullfile(path,'data'),start,count,stride);
else
    Npairs= length(PrimaryDate);
    Stack= nan([grid.Size Npairs],'single');
    for i= 1:length(k)
        start= [iay iax k(i)];
        count= [grid.Size 1];
        
        Stack(:,:,i)= h5read(L1filename,fullfile(path,'data'),start,count);
    end
end

end




