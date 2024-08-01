%% Load Local Step File
% Detail about types 1 and 2 at: http://geodesy.unr.edu/PlugNPlayPortal.php
% Type 3 corresponds to manual steps. The format of type 3 lines is:
%   StationID YYMMMDD 3 Information
%   e.g. ANZA 14MAR01 3 Manual-ZelHurewitz-2024Jan01

function Step= loadOffsetFile(filename)

if ~exist(filename,'file')
    Step= table;
    return
end

S= readlines(filename);

I= contains(S," 1 ") | contains(S," 3 ");
A= S(I);
B= split(A);

if isscalar(A)
    B= B';
end

Step= table;
if ~isempty(B)
    Step.ID= B(:,1);
    Step.Date= datetime(B(:,2),"InputFormat","yyMMMdd");
    Step.Type= str2double(B(:,3));
    Step.Information= B(:,4);
end

I= contains(S," 2 ");
A= S(I);
B= split(A);

if isscalar(A)
    B= B';
end

Step2= table;
if ~isempty(B)
    Step2.ID= B(:,1);
    Step2.Date= datetime(B(:,2),"InputFormat","yyMMMdd");
    Step2.Type= 1+ ones(height(Step2),1);
    Step2.Information= join(B(:,4:end));
end

Step= [Step; Step2];

if ~isempty(Step)
    Step= sortrows(Step,"ID");
end

end



