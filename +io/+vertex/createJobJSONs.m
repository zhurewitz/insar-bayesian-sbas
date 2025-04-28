%% Create Job JSON

function createJobJSONs(FileIDPairs,JobName,Track,OpenFiles)

arguments
    FileIDPairs 
    JobName 
    Track 
    OpenFiles= true;
end

Nframes= height(FileIDPairs);

Nbatches= ceil(Nframes/200);
increment= ceil(Nframes/Nbatches);

if ~exist("Requests",'dir')
    mkdir Requests
end

count= 0;
for batch= 1:Nbatches
    klim= min(count+ [1 increment],Nframes);
    
    thisJobName= sprintf("%s%d Batch%d",JobName,Track,batch);
    JSONfilename= sprintf("Requests/%s-T%d-batch%d.json",JobName,Track,batch);

    io.vertex.writeCustomJobRequest(FileIDPairs(klim(1):klim(2),:),thisJobName,JSONfilename,OpenFiles)
    
    count= count+ increment;
end

end

