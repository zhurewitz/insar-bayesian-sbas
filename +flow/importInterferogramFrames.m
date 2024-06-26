%% Import Interferogram Frames

function importInterferogramFrames(h5filename,filelist,varargin)
%% Optional Input

% Maximum number of interferometric pairs to process
% For instance, to save a reduced size file clone, run:
% importInterferogramFrames(h5filename,filelist,'MaxPairs',2)
maxPairs= utils.parseIn(varargin,'MaxPairs');
if isempty(maxPairs)
    maxPairs= Inf;
end



%% Load Grids

if ~exist(h5filename,'file')
    error('File %s does not exist. Run flow.generateGrid first',h5filename)
end


commonGrid= h5.readGrid(h5filename,'/grid/');
metaGrid= h5.readGrid(h5filename,'/metaGrid/');

dL= commonGrid.dL;
referenceTrendMatrix= h5.read(h5filename,'/grid','referenceTrendMatrix');
commonTrendMatrix= h5.read(h5filename,'/grid','trendMatrix');
metaTrendMatrix= h5.read(h5filename,'/metaGrid','trendMatrix');
OCEAN= h5.read(h5filename,'/grid','oceanMask') == 1;
IN= h5.read(h5filename,'/grid','referenceMask') == 1;




%% Read File Metadata, Remove Long-Baseline Interferograms

frameTable= io.shortMetaData(filelist);

% Remove long temporal baseline interferograms for optimal windowing
Ikeep= (frameTable.SecondaryDate < datetime(2018,10,1) & frameTable.TemporalBaseline < 200) |...
    (frameTable.SecondaryDate >= datetime(2018,10,1) & frameTable.TemporalBaseline <= 36);
frameTable= frameTable(Ikeep,:);

% Remove interferograms which do not connect to the larger network
frameTable= flow.keepConnectedGraph(frameTable);




%% Stitch and Resave Interferograms

% Unique missions and tracks
Missions= unique(frameTable.Mission);
Tracks= unique(frameTable.Track);

t1= utils.tictoc;
for m= 1:length(Missions)
    mission= Missions(m);

    for t= 1:length(Tracks)
        track= Tracks(t);

        I= strcmpi(frameTable.Mission,mission) & frameTable.Track == track;
        if sum(I) == 0
            continue; % No interfereograms with this mission/track combination
        end
        
        subTable= frameTable(I,:);
        
        DatePairs= unique([subTable.PrimaryDate subTable.SecondaryDate],'rows');
        primaryDate= DatePairs(:,1);
        secondaryDate= DatePairs(:,2);
        
        Npairs= length(primaryDate);
        
        
        for k= 1:min(Npairs,maxPairs)
            trackstr= strcat(mission,'-',string(track));
            
            % Check to see if interferogram has already been processed
            path= fullfile('/interferogram/L1-stitched',trackstr);
            pDateWritten= h5.read(h5filename,path,'primaryDate');
            sDateWritten= h5.read(h5filename,path,'secondaryDate');
            
            if ~isempty(pDateWritten) && any(pDateWritten == primaryDate(k) & sDateWritten == secondaryDate(k))
                fprintf('Mission %d/%d. Track %d/%d. Interferogram %d/%d already written, continuing. \n',...
                m,length(Missions), t,length(Tracks), k,Npairs)
                continue
            end
            
            
            %% Load Interferograms
            
            % Names of interferograms to be stitched together
            stitchNames= subTable.Fullname(subTable.PrimaryDate == primaryDate(k) & subTable.SecondaryDate == secondaryDate(k),:);
            
            % Load and stich interferograms
            [infLong,infLat,displacementLOS]= io.stitchInterferograms2(stitchNames);
            % [infLong,infLat,displacementLOS,coherence,mask,metaData]=...
            %     io.stitchInterferograms2(stitchNames);
            
            
            
            %% Place on Common Grid
            
            % Calculate intersection
            [~,ia_long,ib_long]= intersect(round(commonGrid.Long/dL),round(infLong/dL));
            [~,ia_lat,ib_lat]= intersect(round(commonGrid.Lat/dL),round(infLat/dL));
            
            % Add to grid
            if ~isempty(ia_long) && ~isempty(ia_lat)
                % metaData= utils.deleteTableVariable(metaData,'BoundingBox');
                
                LOS= nan(commonGrid.Size,'single');
                LOS(ia_lat,ia_long)= displacementLOS(ib_lat,ib_long);

                LOS(OCEAN)= nan;
            else
                fprintf('Stitched interferogram %d/%d does not intersect. Elapsed time %0.0fs\n',...
                    k,Npairs,toc-t1)
                continue
            end

            
            
            %% Detrend Interferogram to Reference Area
            
            % Estimate trend, excluding missing values
            v= LOS(IN);
            Idata= ~isnan(v);
            p= referenceTrendMatrix(Idata,:)\v(Idata);
            
            % Remove trend
            TREND= reshape(commonTrendMatrix*p,commonGrid.Size);
            LOS= LOS- TREND;
            
            % Preserve trend on metaGrid scale
            trendMeta= reshape(metaTrendMatrix*p,metaGrid.Size);
            
            
            
            %% Look Angle Metadata
            
            basename= '/metaGrid';
            path= fullfile(basename,trackstr);
            
            if k == 1
                [AZ,INC,LOOK,LX,LY,LZ]= io.stitchAngles(stitchNames,metaGrid);
                LOOKVECTOR= cat(3,LX,LY,LZ);
                
                h5.write(h5filename,path,'incidenceAngle',INC);
                h5.writeatts(h5filename,path,'incidenceAngle',...
                    'units','degrees','referenceDirection','up');
                
                h5.write(h5filename,path,'lookAngle',LOOK);
                h5.writeatts(h5filename,path,'lookAngle','units','degrees');
                
                h5.write(h5filename,path,'azimuthAngle',AZ);
                h5.writeatts(h5filename,path,'azimuthAngle',...
                    'units','degrees','origin','ground','pointsTo',...
                    'satellitePosition','referenceDirection','east',...
                    'positiveOrientation','ccw');
                
                h5.write(h5filename,path,'lookVector',LOOKVECTOR);
                h5.writeatts(h5filename,path,'lookVector','units','unitless',...
                    'axis','XYZ= east/north/up','satelliteFacingDirection','towards');
            end
            
            
            %% Save Interferogram to HDF5 ProcessingStore File
            
            h5.writeStitchedInterferogram(h5filename,mission,track,primaryDate(k),...
                secondaryDate(k),LOS,trendMeta);

            fprintf('Mission %d/%d. Track %d/%d. Interferogram %d/%d saved. Elapsed time %0.1f min\n',...
                m,length(Missions), t,length(Tracks), k,Npairs,(toc-t1)/60)
        end
    end
end

end
