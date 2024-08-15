%% Download GNSS Step File from UNR
% Details at: http://geodesy.unr.edu/PlugNPlayPortal.php
% Citation: Blewitt 2018. https://doi.org/10.1029/2018EO104623
% Full citation at above link or DOI

function Step= downloadUNRSteps

UNRStepFile= "http://geodesy.unr.edu/NGLStationPages/steps.txt";

S= readlines(UNRStepFile);

I= contains(S," 1 ");
A= S(I);
B= split(A);

Step= table;
Step.ID= B(:,1);
Step.Date= datetime(B(:,2),"InputFormat","yyMMMdd");
Step.Type= ones(height(Step),1);
Step.Information= B(:,4);

I= contains(S," 2 ");
A= S(I);
B= split(A);

Step2= table;
Step2.ID= B(:,1);
Step2.Date= datetime(B(:,2),"InputFormat","yyMMMdd");
Step2.Type= 1+ ones(height(Step2),1);
Step2.Information= join(B(:,4:end));

Step= [Step; Step2];

Step= sortrows(Step,"ID");

end







%% README File
% Found at: http://geodesy.unr.edu/NGLStationPages/steps_readme.txt
%
% FULL TEXT
%
% Information on database of potential steps in GPS time series
% 
% The steps master file can be found at http://geodesy.unr.edu/NGLStationPages/steps.txt
% Steps pertaining to individual stations are additionally found in a table at the bottom of each station page.
% 
% In steps.txt:
% Column 1 is the station 4-character ID
% 
% Column 2 is the step date in YYMMMDD format
% 
% Column 3 is the step type code where:
%   Code=1 is time of an equipment change from IGS log file (antenna, receiver or firmware change)
%   Code=2 is possible earthquake step where epicenter is within 10^(0.5*mag - 0.8) km of the station
% 
% if Code==1
%   Column 4 is the type of equipment change event
% if Code==2
%   Column 4 is the threshold distance for this event in km.
%   Column 5 is the distance from station to epicenter in km.
%   Column 6 is the event magnitude
%   Column 7 is the USGS event ID. Event information available at http://earthquake.usgs.gov/earthquakes/eventpage/<eventID>
% 
% Potential earthquake related steps are marked if the distance from station to epicenter is less than the threshold distance calculated using a simple formula based on event magnitude: r0 = 10.^(0.5*mag - 0.79) km.
% So a 4 gives 16 km
% a 5 gives 51 km
% a 6 gives 162 km
% a 7 gives 512 km
% an 8 gives 1622 km
% a 9 gives 5129 km
% 
% Event depth, style or directionality of displacement is currently not accounted for in the distance threshold. Actual displacement may not have occurred at the marked time.
% 
% Information in this file is updated daily using automated procedures.

