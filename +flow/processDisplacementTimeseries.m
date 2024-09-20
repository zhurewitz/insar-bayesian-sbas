%% Process Displacement Timeseries

function processDisplacementTimeseries(L1filename,L3filename,Bscale,tau)

arguments
    L1filename
    L3filename= [];
    Bscale= 10;
    tau= 60/365;
end

if isempty(L3filename)
    L3filename= L1filename;
end

[Missions,Tracks]= io.readMissionTracks(L1filename,'L1');

t2= utils.tictoc;
for m= 1:length(Missions)
    Mission= Missions(m);
    for t= 1:length(Tracks)
        Track= Tracks(t);

        basepathL1= '/interferogram/L1-stitched';
        basepathL3= '/timeseries/L3-displacement';
        name= strcat(Mission,'-',string(Track));
        pathL1= fullfile(basepathL1,name);
        pathL3= fullfile(basepathL3,name);
        
        if ~h5.exist(L1filename,pathL1)
            continue
        end

        Mission= Missions(m);
        Track= Tracks(t);
        
        [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
        
        S= h5info(L1filename,fullfile(pathL1,'data'));
        ChunkSize= S.ChunkSize;
        Size= S.Dataspace.MaxSize;
        
        NtilesY= ceil(Size(1)/ChunkSize(1));
        NtilesX= ceil(Size(2)/ChunkSize(2));

        for ty= 1:NtilesY
            for tx= 1:NtilesX
                % Check to see if stack has been processed before
                if h5.exist(L3filename,pathL3,'data')
                    Chunk= h5.readChunk(L3filename,pathL3,'data',ty,tx,1);

                    if any(~isnan(Chunk),'all')
                        fprintf('Mission %d/%d. Track %d/%d. Tile %d/%d already processed, continuing. Elapsed time %0.1fmin.\n',...
                            m,length(Missions),t,length(Tracks),(ty-1)*NtilesX+tx,NtilesY*NtilesX,(toc-t2)/60)
                        continue
                    end
                end
                
                % Load chunk stack
                Stack= loadInterferogramStack(L1filename,Mission,Track,tx,ty);
                
                if all(isnan(Stack),'all')
                    continue
                end

                % Estimate displacement timeseries from interferogram stack
                [Optimizer,Date,ReferenceDate,PosteriorCovariance,SBASTimeseries]= ...
                    flow.estimateDisplacementTimeseries(Stack,PrimaryDate,SecondaryDate,Bscale,tau);


                % Save timeseries
                saveTimeseries(L3filename,Mission,Track,Size,ChunkSize,tx,ty,...
                    Optimizer,Date,ReferenceDate,SBASTimeseries)
                
                % Save posterior covariance
                saveCovariance(L3filename,Mission,Track,tx,ty,NtilesX,NtilesY,...
                    PosteriorCovariance)
                
                fprintf('Mission %d/%d. Track %d/%d. Tile %d/%d processed. Elapsed time %0.1fmin.\n',...
                m,length(Missions),t,length(Tracks),(ty-1)*NtilesX+tx,NtilesY*NtilesX,(toc-t2)/60)
            end
        end
        
    end
end

end




%% Load Stack of Interferograms

function Stack= loadInterferogramStack(L1filename,Mission,Track,tx,ty)

basepath= '/interferogram/L1-stitched';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

Stack= h5.readChunkStack(L1filename,path,'data',ty,tx);

end



%% Save Timeseries

function saveTimeseries(L3filename,Mission,Track,Size,ChunkSize,tx,ty,...
    Optimizer,Date,ReferenceDate,SBASTimeseries)

basepath= '/timeseries/L3-displacement';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

start= [ChunkSize(1)*(ty-1)+1 ChunkSize(2)*(tx-1)+1 1];

h5.writeStackInf(L3filename,path,'data',single(Optimizer),Size,start,ChunkSize)
h5.writeatts(L3filename,path,'data','description','Posterior mean',...
    'units','mm','direction','LOS','orientation','upwards')

h5.writeStackInf(L3filename,path,'SBAS',single(SBASTimeseries),Size,start,ChunkSize)
h5.writeatts(L3filename,path,'SBAS','description','Traditional SBAS',...
    'units','mm','direction','LOS','orientation','upwards')

h5.writeInf(L3filename,path,'date',Date)
h5.writeScalar(L3filename,path,'referenceDate',ReferenceDate)

end



%% Save Posterior Covariance

function saveCovariance(L3filename,Mission,Track,tx,ty,NtilesX,NtilesY,...
    PosteriorCovariance)

basepath= '/timeseries/L3-displacement';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);
datasetname= fullfile(path,'posteriorCovariance');

Ndate= height(PosteriorCovariance);

datasetsize= [Ndate Ndate NtilesX NtilesY];
chunksize= [Ndate Ndate 1 1];

if ~h5.exist(L3filename,datasetname)
    h5create(L3filename,datasetname,datasetsize,"Datatype",'single',...
        'Chunksize',chunksize,'Deflate',3,'Shuffle',true,'Fletcher32',true);
end

start= [1 1 tx ty];
count= [Ndate Ndate 1 1];

h5write(L3filename,datasetname,single(PosteriorCovariance),start,count);
h5.writeatts(L3filename,path,'posteriorCovariance','description',...
    'Posterior covariance matrix','units','mm^2','direction','LOS','orientation','upwards')

end





% function copyAttributes(L1filename,L2filename,Mission,Track)
% 
% if isempty(L2filename)
%     L2filename= L1filename;
% end
% 
% trackstr= strcat(Mission,'-',string(Track));
% 
% L1basepath= '/interferogram/L1-stitched';
% L2basepath= '/interferogram/L2-closureCorrected';
% 
% L1path= fullfile(L1basepath,trackstr);
% L2path= fullfile(L2basepath,trackstr);
% 
% Attributes= h5.readatts(L1filename,L1path);
% h5.writeatts(L2filename,L2path,'',Attributes{:})
% 
% Attributes= h5.readatts(L1filename,L1path,'data');
% h5.writeatts(L2filename,L2path,'data',Attributes{:})
% 
% end