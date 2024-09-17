%% Read Corrected GNSS Displacements

function Segments= readCorrectedGNSSDisplacement(ID,correctionXMLFile)

arguments
    ID
    correctionXMLFile= [];
end

if isempty(correctionXMLFile)
    [Date,Displacement]= gnss.downloadUNRTimeseries(ID);
    T= table;
    T.Date= Date;
    T.East= Displacement(:,1);
    T.North= Displacement(:,2);
    T.Up= Displacement(:,3);
    Segments{1}= T;
    return
end



S= readstruct(correctionXMLFile);
Station= S.Station(strcmp([S.Station.idAttribute],ID));

isQuality= isempty(Station) || ~isfield(Station,"Quality") ||...
    ismissing(Station.Quality) || strcmp(Station.Quality.Value,"true");
% Note: If there is no quality information present, the station is assumed
% to be of usable quality

if ~isQuality
    Segments= {};
    return;
end

% Load GNSS timeseries
[Date,Displacement]= gnss.downloadUNRTimeseries(ID);

if isempty(Station)
    T= table;
    T.Date= Date;
    T.East= Displacement(:,1);
    T.North= Displacement(:,2);
    T.Up= Displacement(:,3);
    Segments{1}= T;
    return
end


%% Remove Outliers

if isfield(Station,"Outlier") && any(~ismissing(Station.Outlier))
    for i= 1:length(Station.Outlier)
        Outlier= Station.Outlier(i);
        
        if ~isfield(Outlier,"Date") || ismissing(Outlier.Date)
            continue
        end
        
        % Remove outlier
        I= Date == Outlier.Date;
        Date(I)= [];
        Displacement(I,:)= [];
    end
end



%% Correct Offsets

if isfield(Station,"Offset") && any(~ismissing(Station.Offset))
    for i= 1:length(Station.Offset)
        Offset= Station.Offset(i);
        
        if ~isfield(Offset,"Date") || ismissing(Offset.Date)
            continue
        end
        
        OffsetDate= Offset.Date;
        
        % Estimate the magnitude of the offset
        stepSize= gnss.estimateOffsetMagnitude(Date,Displacement,OffsetDate);
        
        % If magnitude is specified in the file, use that value instead
        if isfield(Offset,"East") && ~ismissing(Offset.East)
            stepSize(1)= Offset.East;
        end
        if isfield(Offset,"North") && ~ismissing(Offset.North)
            stepSize(2)= Offset.North;
        end
        if isfield(Offset,"Up") && ~ismissing(Offset.Up)
            stepSize(3)= Offset.Up;
        end
        
        % Correct offset
        Displacement(Date > OffsetDate,:)= ...
            Displacement(Date > OffsetDate,:)- stepSize;
    end
end



%% Separate into Ranges

if isfield(Station,"Range") && any(~ismissing(Station.Range))
    
    Nranges= length(Station.Range);
    Segments= cell(Nranges,1);
    
    for i= 1:Nranges
        if isfield(Station.Range,'Start') && ~ismissing(Station.Range(i).Start)
            StartDate= Station.Range(i).Start;
        else
            StartDate= Date(1);
        end
        if isfield(Station.Range,'End') && ~ismissing(Station.Range(i).End)
            EndDate= Station.Range(i).End;
        else
            EndDate= Date(end);
        end
        
        I= StartDate <= Date & Date <= EndDate;
        T= table;
        T.Date= Date(I);
        T.East= Displacement(I,1);
        T.North= Displacement(I,2);
        T.Up= Displacement(I,3);
        Segments{i}= T;
    end
else
    T= table;
    T.Date= Date;
    T.East= Displacement(:,1);
    T.North= Displacement(:,2);
    T.Up= Displacement(:,3);
    Segments{1}= T;
end

end
