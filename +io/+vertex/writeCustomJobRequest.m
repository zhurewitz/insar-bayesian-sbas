%% Write Custom Job Request

function writeCustomJobRequest(fileIDPairs,jobName,JSONfilename,openFile)

arguments
    fileIDPairs 
    jobName 
    JSONfilename 
    openFile= false;
end

S= struct;
S.validate_only= false;

job= struct;
job.job_type= "INSAR_GAMMA";
job.name= jobName;

for i= 1:height(fileIDPairs)
    jp= struct;
    jp.granules= fileIDPairs(i,:);
    jp.include_look_vectors= false;
    jp.include_los_displacement= false;
    jp.include_displacement_maps= false;
    jp.include_inc_map= false;
    jp.include_dem= false;
    jp.include_wrapped_phase= false;
    jp.apply_water_mask= true;
    jp.looks= "20x4";
    jp.phase_filter_parameter= 0.6;
    job.job_parameters= jp;
    S.jobs(i)= job;
end

writestruct(S,JSONfilename,"FileType","json","PrettyPrint",true)

if openFile
    setenv("filenameToOpen",JSONfilename)
    !open -a /System/Applications/TextEdit.app $filenameToOpen
end

end



