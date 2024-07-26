%% Process Displacement Timeseries

function processDisplacementTimeseries(L1filename,L3filename)

arguments
    L1filename
    L3filename= [];
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

        path= '/interferogram/L1-stitched';
        name= strcat(Mission,'-',string(Track));
        if ~h5.exist(L1filename,path,name)
            continue
        end

        Mission= Missions(m);
        Track= Tracks(t);
        
        [PrimaryDate,SecondaryDate]= io.loadDates(L1filename,'L1',Mission,Track);
        
        S= h5info(L1filename,fullfile('/interferogram/L1-stitched/',name,'data'));
        ChunkSize= S.ChunkSize;
        Size= S.Dataspace.MaxSize;
        
        NtilesY= ceil(Size(1)/ChunkSize(1));
        NtilesX= ceil(Size(2)/ChunkSize(2));

        for ty= 1:NtilesY
            for tx= 1:NtilesX
                % Load chunk stack
                Stack= loadInterferogramStack(L1filename,Mission,Track,ChunkSize,tx,ty);
                
                if all(isnan(Stack),'all')
                    continue
                end

                % Estimate displacement timeseries from interferogram stack
                [Optimizer,Date,ReferenceDate,PosteriorCovariance]= ...
                    flow.estimateDisplacementTimeseries(Stack,PrimaryDate,SecondaryDate);


                % Save timeseries
                saveTimeseries(L3filename,Mission,Track,Size,ChunkSize,tx,ty,Optimizer,Date,ReferenceDate,PosteriorCovariance)
                
                fprintf('Mission %d/%d. Track %d/%d. Tile %d/%d processed. Elapsed time %0.1fmin.\n',...
                m,length(Missions),t,length(Tracks),(ty-1)*NtilesX+tx,NtilesY*NtilesX,(toc-t2)/60)
            end
        end
        
    end
end

end




%% Load Stack of Interferograms

function Stack= loadInterferogramStack(L1filename,Mission,Track,ChunkSize,tx,ty)

basepath= '/interferogram/L1-stitched';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

start= [ChunkSize(1)*(ty-1)+1 ChunkSize(2)*(tx-1)+1 1];
count= [ChunkSize(1:2) Inf];

Stack= h5read(L1filename,fullfile(path,'data'),start,count);

end


%% Save Timeseries
function saveTimeseries(L3filename,Mission,Track,Size,ChunkSize,tx,ty,...
    Optimizer,Date,ReferenceDate,PosteriorCovariance)

basepath= '/timeseries/L3-displacement';
trackstr= strcat(Mission,'-',string(Track));
path= fullfile(basepath,trackstr);

start= [ChunkSize(1)*(ty-1)+1 ChunkSize(2)*(tx-1)+1 1];
% count= [ChunkSize(1:2) Inf];

h5.writeStackInf(L3filename,path,'data',single(Optimizer),Size,start,ChunkSize)

h5.writeInf(L3filename,path,'date',Date)
h5.writeScalar(L3filename,path,'referenceDate',ReferenceDate)

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



% %% Plot
                % figure(1)
                % h= pcolor(Optimizer(:,:,1));
                % shading flat
                %
                % for k= 1:length(Date)
                %     h.CData= Optimizer(:,:,k);
                %     drawnow
                %     pause(.1)
                % end