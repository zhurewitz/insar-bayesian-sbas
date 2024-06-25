%% Read Binary World Vector Shoreline File
% https://shoreline.noaa.gov/data/datasheets/wvs.html
% https://www.ngdc.noaa.gov/mgg/shorelines/

function [coastlineStruct, levelNames]= readBinaryWVSFile(binaryWVSFilename)

fID= fopen(binaryWVSFilename);

A= fread(fID,'int32','b');

n= 1;
Ntot= length(A);
coastlineStruct= struct();

i= 1;
while n< Ntot
    N= A(n+1);
    
    flag= A(n+2);
    level= bitand(flag,255,'int32');
    % Values: 1 land, 2 lake, 3 island_in_lake, 4 pond_in_island_in_lake
    
    west= A(n+3)/1e6;
    east= A(n+4)/1e6;
    we= clamplongitude([west east]);
    west= we(1);
    east= we(2);
    south= A(n+5)/1e6;
    north= A(n+6)/1e6;
    
    container= A(n+9);
    
    ninit= n+ 11;
    nfinal= n+ 11+ 2*N- 1;
    
    DATA= A(ninit:nfinal)/1e6;
    DATA= reshape(DATA,2,[])';
    long= DATA(:,1);
    long= clamplongitude(long);
    
    lat= DATA(:,2);

    coastlineStruct(i).id= A(n);
    coastlineStruct(i).N= N;
    coastlineStruct(i).level= level;
    coastlineStruct(i).west= west;
    coastlineStruct(i).east= east;
    coastlineStruct(i).north= north;
    coastlineStruct(i).south= south;
    coastlineStruct(i).container= container;
    coastlineStruct(i).long= long;
    coastlineStruct(i).lat= lat;

    i= i+1;
    n= nfinal+1;
end


levelNames= ["land" "lake" "island_in_lake" "pond_in_island_in_lake"];

fclose(fID);


coastlineStruct(1).east= coastlineStruct(1).east+ 360; 
% Bug fix: Eurasia's "east" value was negative but should be positive
% for consistency

end





%% Clamp Longitude from -180 to 180

function long= clamplongitude(long)
long(long> 180)= long(long> 180)- 360;

% If shoreline crosses the 180 degree mark, constrain it to -150:210 instead
if any(abs(diff(long)) > 330)
    long(long < -150)= long(long < -150)+ 360;
end

end


