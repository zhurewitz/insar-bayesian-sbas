%% Missing Interferograms
% Finds FileID pairs corresponding to interferogram frames which are
% missing from the currently downloaded dataset

function FileIDPairs = missingInterferograms(...
    SLCJSONfilename, datadir, Track, LongLim, LatLim, DatePairs)


% Read metadata from SLC JSON file
T= io.vertex.readSLCInformation(SLCJSONfilename);

% Read metadata from downloaded files
[~,filelist]= io.listDirectory(datadir);
metaData= io.shortMetaData(filelist);
metaData= metaData(metaData.Track == Track,:);

Ndir= length(filelist);

for i= 1:Ndir
    dirname= filelist(i);
    
    metaData.referenceGranule(i)= io.hyp3.readMetaData(dirname,"Reference Granule");
    metaData.secondaryGranule(i)= io.hyp3.readMetaData(dirname,"Secondary Granule");
    
    fprintf("Read metadata from file %d/%d\n",i,Ndir)
end



%% Interferogram Information

S= struct;
for k= 1:height(DatePairs)
    PrimaryDate= DatePairs(k,1);
    SecondaryDate= DatePairs(k,2);
    
    S(k).PrimaryDate= PrimaryDate;
    S(k).SecondaryDate= SecondaryDate;
    
    Index1= find(T.Date == PrimaryDate);
    Index2= find(T.Date == SecondaryDate);
    
    count= 1;
    for i= 1:length(Index1)
        for j= 1:length(Index2)
            T1= T(Index1(i),:);
            T2= T(Index2(j),:);
            
            p= intersect(T1.Polyshape,T2.Polyshape);
            
            IDSLC= sort([T1.FileID T2.FileID]);
            IDDownloaded= sort([metaData.referenceGranule metaData.secondaryGranule],2);
            
            S(k).Interferogram(count).Polyshape= p;
            S(k).Interferogram(count).ReferenceGranule= T1.FileID;
            S(k).Interferogram(count).SecondaryGranule= T2.FileID;
            S(k).Interferogram(count).Downloaded= any(all(IDSLC == IDDownloaded,2));
            S(k).Interferogram(count).Need= false;
            S(k).Interferogram(count).Index= count;
            
            count= count+1;
        end
    end
end



%% Select the Interferograms Needed to Complete the Scene

% Bounding box polygon
boundingPolyshape= polyshape(LongLim([1 2 2 1]), LatLim([1 1 2 2]));


for k= 1:length(S)
    try
        Inf= struct2table([S(k).Interferogram]);
    catch
        1
    end
    
    if any(Inf.Downloaded)
        DownloadRegion= union(Inf.Polyshape(Inf.Downloaded));
    else
        DownloadRegion= polyshape;
    end

    RemainingRegion= subtract(boundingPolyshape,DownloadRegion);
    
    if area(RemainingRegion) > 1e-6
        % Interferograms which could be generated
        PotentialInf= Inf(~Inf.Downloaded,:);
        
        % Sort by area of intersection with the remaining region
        PotentialInf.IntersectionArea= area(intersect(PotentialInf.Polyshape, RemainingRegion));
        PotentialInf= sortrows(PotentialInf,"IntersectionArea","descend");
        PotentialInf(PotentialInf.IntersectionArea < 1e-6,:)= []; % Remove zero areas
        
        currentRemainingRegion= RemainingRegion;
        for q= 1:height(PotentialInf)
            % Subtract the interferograms region from the current remaining
            % region
            tmpRemainingRegion= subtract(currentRemainingRegion, PotentialInf.Polyshape(q));
            
            % If it meaningfully reduces the area, this means that this
            % interferogram is worth downloading
            if area(tmpRemainingRegion) < area(currentRemainingRegion) - 1e-6
                PotentialInf.Need(q)= true;
                
                currentRemainingRegion= tmpRemainingRegion;
            end
        end
        
        % Set the "Need" values in the S struct
        NeededIndices= PotentialInf.Index(PotentialInf.Need);
        for i= 1:length(NeededIndices)
            S(k).Interferogram(NeededIndices(i)).Need= true;
        end
    end
end



%% SLC Pair Names

FileIDPairs= [];

for k= 1:length(S)
    for i= 1:length(S(k).Interferogram)
        if S(k).Interferogram(i).Need
            FileIDPairs= [FileIDPairs
                S(k).Interferogram(i).ReferenceGranule...
                S(k).Interferogram(i).SecondaryGranule]; %#ok<AGROW>
        end
    end
end


end