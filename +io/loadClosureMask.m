%% Load Closure Mask from H5File

function closureMask= loadClosureMask(L2filename,Mission,Track,PrimaryDate,SecondaryDate)

arguments
    L2filename
    Mission
    Track
    PrimaryDate (1,1)
    SecondaryDate (1,1)
end


if ~h5.exist(L2filename)
    error('File does not exist')
end

[currentPrimaryDate,currentSecondaryDate]= io.loadDates(L2filename,'closureMask',Mission,Track);

if isempty(currentPrimaryDate)
    closureMask= [];
    return
end

k= currentPrimaryDate == PrimaryDate & currentSecondaryDate == SecondaryDate;

if isempty(k)
    closureMask= [];
    return
end

basepath= '/interferogram/L2-closureCorrected';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr,'closureMask');


commonGrid= h5.readGrid(L2filename,'/grid');

start= [1 1 find(k,1)];
count= [commonGrid.Size 1];

closureMask= h5.read(L2filename,path,'mask',start,count) == 1;

end

