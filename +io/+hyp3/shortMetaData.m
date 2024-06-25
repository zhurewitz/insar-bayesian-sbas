%% Short Meta Data

function metaData= shortMetaData(filelist)

[dirs,names,~]= fileparts(filelist);

metaData= table;

Nframes= length(names);

metaData.ProcessingCenter= repmat("HYP3",Nframes,1);
metaData.Mission= repmat("S1",Nframes,1);
metaData.Band= repmat("C",Nframes,1);

for i= 1:Nframes
    dir= dirs(i);
    name= names(i);
    
    [Track,Direction]= io.hyp3.readTrack(dir,name);
    
    metaData.Track(i)= Track;
    metaData.Direction(i)= Direction;
    
    [PrimaryDate,SecondaryDate,TimeForward,TemporalBaseline]= io.hyp3.readDates(name);
    
    metaData.PrimaryDate(i)= PrimaryDate;
    metaData.SecondaryDate(i)= SecondaryDate;
    metaData.TemporalBaseline(i)= TemporalBaseline;
    metaData.TimeForward(i)= TimeForward;
end

metaData.Filename= names;
metaData.Fullname= fullfile(dirs,names);

end