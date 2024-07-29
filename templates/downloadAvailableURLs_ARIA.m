%% Download Available ARIA Interferogram URLs


% User Input
LatLim= [34.75 37.75];
LongLim= [-122 -118];

Mission= "S1";
Track= 144;

outputDirectory= "Data";

Version= "v3_0_1";




%% Save File

savefile= fullfile(outputDirectory,sprintf('allAvailableURLs_%s_%d_ARIA_%s.txt',Mission,Track,Version));


%% API Options

baseURL= "https://api.daac.asf.alaska.edu/services/search/param?";

intersectWithString= sprintf('intersectsWith=polygon%%28%%28%g+%g,%g+%g,%g+%g,%g+%g,%g+%g%%29%%29',...
    LongLim(1),LatLim(1),LongLim(1),LatLim(2),LongLim(2),LatLim(2),...
    LongLim(2),LatLim(1),LongLim(1),LatLim(1));


datasetString= "dataset=ARIA%20S1%20GUNW";

trackString= sprintf('relativeOrbit=%d',Track);
maxResultsString= "maxResults=10";

options= weboptions("Timeout",60,"RequestMethod",'post');



%% Request File URLs

startDate= datetime(2014,1,1);

downloadURL= [];

count= 1;

% Initialize endDate so that the while-loop starts
endDate= startDate;

t0= utils.tictoc;
while endDate < datetime('today')
    % Set initial date range very high
    dateRange= 2*min(365*10,days(datetime('today')-startDate));
    outputCount= Inf;

    % Find a date range so that information about less than 2500 files will
    % be downloaded at a time (the server can't handle very large requests)
    while outputCount > 2500
        % Half the date range each iteration
        dateRange= ceil(dateRange/2);
        
        % Final date
        endDate= startDate+ dateRange;
        
        startString= sprintf("start=%s",string(startDate,"MMM+dd,+yyyy"));
        endString= sprintf("end=%s",string(endDate,"MMM+dd,+yyyy"));
        
        countAPIurl= strcat(baseURL,intersectWithString,'&',datasetString,'&',trackString,...
            '&',startString,'&',endString,'&',"output=count");

        % Request the number of output files from ASF
        for it= 1:5
            try
                outputCount= str2double(webread(countAPIurl,options));
                break
            catch
                fprintf('Count request failed on try %d/5. Trying again: %s\n',it,countAPIurl)
                
                % Try once more, to let the error be seen
                if it == 5
                    outputCount= str2double(webread(countAPIurl,options));
                end
            end
        end
    end

    % Generate request API URL 
    APIurl= strcat(baseURL,intersectWithString,'&',datasetString,'&',trackString,...
        '&',startString,'&',endString,'&',"output=CSV");
    
    % Temporary filename
    tmpfilename= strcat(tempname,'.csv');
    
    % Download CSV from ASF and save
    for i= 1:5
        try
            websave(tmpfilename,APIurl,options);
            break
        catch
            fprintf('List request failed on try %d/5. Trying again: %s\n',it,countAPIurl)
            
            % Try once more, to let the error be seen
            if it == 5
                websave(tmpfilename,APIurl,options);
            end
        end
    end

    % Read as table
    T= readtable(tmpfilename);
    
    % Extract the URLs
    URL= string(T.Var26);

    % Valid URLs only
    I= matches(URL,'https://grfn.asf.alaska.edu/door/download/'+ wildcardPattern+ '.nc');
    validURL= URL(I);

    % Select only files with correct version number
    metaData= io.aria.shortMetaData2(validURL);
    I= strcmpi(metaData.Version,Version);
    selectedURL= validURL(I);
    
    % Add files to list, omitting duplicates
    if isempty(downloadURL)
        downloadURL= selectedURL;
    else
        downloadURL= union(downloadURL,selectedURL);
    end
    
    % Save file
    writelines(downloadURL,savefile)
    
    fprintf('Track %d. Downloaded %d file URLs from %s to %s. Total files: %d\n',...
        Track,length(selectedURL),...
        string(startDate,'yyyy'),string(endDate,'yyyy'), ...
        length(downloadURL))
    
    startDate= endDate;
end

