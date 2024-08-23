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
Elevation= h5.read(h5filename,'/grid','elevation');




%% Stitch and Resave Interferograms

% Read File Metadata
frameTable= io.shortMetaData(filelist);

% Unique missions and tracks
Missions= unique(frameTable.Mission);
Tracks= unique(frameTable.Track);

fprintf('Beginning import of %d frames\n',height(frameTable))
fprintf('Missions: %s\n',sprintf('%s ',Missions))
fprintf('Tracks: %s\n',sprintf('%d ',Tracks))

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
            warning off
            [infLong,infLat,displacementLOS, coherence, connComp,~,errorFlag]= ...
                io.stitchInterferograms(stitchNames);
            warning on
            
            if errorFlag
                warning('Interferogram frames [%s] cannot be stitched together, omitting',...
                    strjoin(stitchNames))
                continue
            end
            
            
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
                
                COH= nan(commonGrid.Size,'single');
                COH(ia_lat,ia_long)= coherence(ib_lat,ib_long);
                COH(OCEAN)= nan;
                
                if ~isempty(connComp)
                    CON= false(commonGrid.Size);
                    CON(ia_lat,ia_long)= connComp(ib_lat,ib_long);
                    CON(OCEAN)= false;
                else
                    CON= [];
                end
            else
                fprintf('Stitched interferogram %d/%d does not intersect. Elapsed time %0.0fs\n',...
                    k,Npairs,toc-t1)
                continue
            end

            
            %% Detrend Interferogram by Elevation
            % Stratified atmosphere can cause elevation-correlated signals
            % in the interferograms. Correct by removing the linear trend
            % with elevation. Only evaluate using high-coherence pixels.
            
            I= ~isnan(LOS) & ~isnan(Elevation) & COH >= 0.7;
            [p,~,mu]= polyfit(Elevation(I),LOS(I),1);
            correction= polyval(p,Elevation,[],mu);
            LOS= LOS- correction;
            elevationTrend= p(1);
            
            
            %% Detrend Interferogram to Reference Area
            
            % Estimate trend to reference area, excluding missing values
            % and low-coherence pixels.
            v= LOS(IN & COH >= 0.7);
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
                [AZ,INC,LX,LY,LZ]= io.stitchAngles(stitchNames,metaGrid);
                LOOKVECTOR= cat(3,LX,LY,LZ);
                
                h5.write(h5filename,path,'incidenceAngle',INC);
                h5.writeatts(h5filename,path,'incidenceAngle',...
                    'units','degrees','referenceDirection','up');
 
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
            
            writeStitchedInterferogram(h5filename,mission,track,primaryDate(k),...
                secondaryDate(k),LOS,trendMeta,COH,CON,elevationTrend);

            fprintf('Mission %d/%d. Track %d/%d. Interferogram %d/%d saved. Elapsed time %0.1f min\n',...
                m,length(Missions), t,length(Tracks), k,Npairs,(toc-t1)/60)
        end
    end
end

end









%% Write L1 Stitched Interferogram to H5 Processing File

function writeStitchedInterferogram(L1filename,Mission,Track,PrimaryDate,...
    SecondaryDate,LOS,trendMeta,COH,CON,elevationTrend)

basename= '/interferogram/L1-stitched/';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basename,trackstr);

[PRIMARYDATE,SECONDARYDATE]= io.loadDates(L1filename,'L1',Mission,Track);

if isempty(PRIMARYDATE)
    k= 1;
else
    % Find where to place data if location already exists
    I= PrimaryDate == PRIMARYDATE & SecondaryDate == SECONDARYDATE;
    if any(I)
        if sum(I) > 1
            error('Data for this date pair somehow exists multiple times already')
        end
        k= find(I,1);
    else
        k= length(PRIMARYDATE)+ 1;
    end
end

% Write to file
h5.write2DInf(L1filename,path,'data',LOS,k,[300 300 1],3)
h5.writeatts(L1filename,path,'data','units','mm','direction','LOS','orientation','upwards')

h5.writeatts(L1filename,path,'','mission',Mission,'track',Track,'direction','PLACEHOLDER')

h5.writeScalar(L1filename,path,'primaryDate',PrimaryDate,Inf,k)
h5.writeScalar(L1filename,path,'secondaryDate',SecondaryDate,Inf,k)

h5.write2DInf(L1filename,path,'trendMeta',trendMeta,k,[size(trendMeta) 1])
h5.writeatts(L1filename,path,'trendMeta','units','mm')

% Write coherence and connComp
h5.write2DInf(L1filename,path,'coherence',COH,k,[300 300 1],3)
if ~isempty(CON)
    h5.write2DInf(L1filename,path,'connComp',CON,k,[300 300 1],3)
end

h5.writeInf(L1filename,path,'elevationTrend',elevationTrend)
h5.writeatts(L1filename,path,'elevationTrend','units','mm/m')

end