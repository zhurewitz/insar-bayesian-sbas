%% Load GNSS Timeseries
% Correct offsets and reference temporally.
% For information about the Outlier, DataGap, and Offset files, see their
% resepective read functions in the +gnss folder

function [Date,Displacement]= loadGNSSTimeseries(ID,OutlierFile,DataGapFile,OffsetFile,...
    StartDate,EndDate,ReferenceDate,RemoveGaps,RemoveCampaign)

arguments
    ID
    OutlierFile= [];
    DataGapFile= [];
    OffsetFile= [];
    StartDate= [];
    EndDate= [];
    ReferenceDate= [];
    RemoveGaps (1,1) {mustBeA(RemoveGaps,'logical')}= true;
    RemoveCampaign (1,1) {mustBeA(RemoveCampaign,'logical')}= true;
end

if isempty(StartDate)
    StartDate= datetime(2015,1,1);
end

if isempty(EndDate)
    EndDate= datetime(2024,10,1);
end

if isempty(ReferenceDate)
    ReferenceDate= StartDate;
end




%% 0. Read Manual Information from Text Files


% Read outliers from files
if ~isempty(OutlierFile)
    OutlierDates= gnss.readOutlierFile(OutlierFile,ID);
else
    OutlierDates= [];
end
if isempty(OutlierDates)
    OutlierDates= datetime.empty;
end


% Read data gaps from file
if ~isempty(DataGapFile)
    [GapStart, GapEnd]= gnss.readGapFile(DataGapFile,ID);
else
    GapStart= [];
    GapEnd= [];
end
if isempty(GapStart)
    GapStart= datetime.empty;
end
if isempty(GapEnd)
    GapEnd= datetime.empty;
end


% Read offset dates from file
if ~isempty(OffsetFile)
    OffsetDates= gnss.readOffsetFile(OffsetFile,ID);
else
    OffsetDates= [];
end









%% 1. Download GNSS Timeseries from UNR

[GDate,GDisplacement,~]= gnss.downloadUNRTimeseries(ID);

% Interpolate to regular posting within specified time window
Date= (StartDate:EndDate)';
Displacement= interp1(GDate,GDisplacement,Date);

% If none, you're done!
if all(isnan(Displacement),'all')
    return
end




%% 2. Remove Manual Outliers

[~,ia,~]= intersect(Date,OutlierDates);
Displacement(ia,:)= nan;




%% 3. Remove Gaps

if RemoveGaps
    % Automatically find gaps of greater than 7 days
    d= days(diff(GDate));
    I= find(d > 7);
    GapStart= [GapStart; GDate(I)];
    GapEnd= [GapEnd; GDate(I+1)];

    % Remove automatic AND manual gaps
    for k= 1:length(GapStart)
        Displacement(Date >= GapStart(k) & Date <= GapEnd(k),:)= nan;
    end
end





%% 4. Additionally Remove "Campaigns"
% When there is less than 30 days of continuous data

if RemoveCampaign
    I= ~any(isnan(Displacement),2);

    [Istart,Iend,Value]= utils.uniqueRegions(I);
    Istart= Istart(Value);
    Iend= Iend(Value);
    d= Iend-Istart;

    I= find(d < 30);

    for k= 1:length(I)
        Displacement(Istart(I(k)):Iend(I(k)),:)= nan;
    end
end





%% 5. Correct Offsets

% Generate parameter fit matrix
% Include velocity, Ridgecrest co-seismic & post-seismic, and annual
ParameterMatrix= utils.parameterMatrix2(Date,1,1,1,1,0,ReferenceDate,1.8);

% Offset correction is found below. 
Displacement= correctOffsets(Date,Displacement,unique(OffsetDates),ParameterMatrix);





%% 6. Temporally Reference

% Fit parameters
Params= utils.fitParams(Displacement,ParameterMatrix);

% Isolate static offset
I= find(all(ParameterMatrix == 1),1); % Corresponds to column of 1s
StaticOffset= Params(I,:);

% Remove
Displacement= Displacement- StaticOffset;





end














%% Correct Offsets
% Fit the parameterized function with the addition of Heaviside functions
% centered on all the offset dates, then remove only the Heavisides.

function Displacement= correctOffsets(Date,Displacement,OffsetDates,ParameterMatrix)

arguments
    Date (:,1)
    Displacement
    OffsetDates
    ParameterMatrix
end

if isempty(OffsetDates)
    OffsetDates= datetime.empty;
end

% Only include those within the time range
OffsetDates= OffsetDates(Date(1) < OffsetDates & OffsetDates < Date(end));

% If none, you're done!
if isempty(OffsetDates)
    return
end

Nparams= width(ParameterMatrix);

% Append offset Heaviside steps to parameter matrix
OffsetDates= reshape(OffsetDates,1,[]);
StepMatrix= Date >= OffsetDates;
ParameterMatrix= [ParameterMatrix StepMatrix];

% Fit parameters
Params= utils.fitParams(Displacement,ParameterMatrix);
StepParams= Params(Nparams+1:end,:);

% Offset fit
StepFit= StepMatrix*StepParams;

% Remove
Displacement= Displacement- StepFit;

end

